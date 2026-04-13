#!/usr/bin/env ruby
# frozen_string_literal: true

# Harness: tool dispatch -- expanding what the model can reach.
#
# tool_calls.rb - Tool dispatch + message normalization
# The agent loop from s01 didn't change. We added tools to the dispatch map,
# and a normalize_messages function that cleans up the message list before
# each API call.
# Key insight: "The loop didn't change at all. I just added tools."

require 'anthropic'
require 'dotenv'
require 'pathname'
require 'open3'
require 'timeout'
require 'set'

$stdout.sync = true

Dotenv.overload

ENV.delete('ANTHROPIC_AUTH_TOKEN') if ENV['ANTHROPIC_BASE_URL']

WORKDIR = Pathname.pwd

client_opts = {}
client_opts[:uri_base] = ENV['ANTHROPIC_BASE_URL'] if ENV['ANTHROPIC_BASE_URL']
CLIENT = Anthropic::Client.new(**client_opts)

MODEL = ENV.fetch('MODEL_ID')
SYSTEM_PROMPT = "You are a coding agent at #{WORKDIR}. Use tools to solve tasks. Act, don't explain."

def safe_path(relative)
  path = (WORKDIR / relative).expand_path
  raise ArgumentError, "Path escapes workspace: #{relative}" unless path.to_s.start_with?("#{WORKDIR}/")

  path
end

def run_bash(command)
  dangerous = ['rm -rf /', 'sudo', 'shutdown', 'reboot', '> /dev/']
  return 'Error: Dangerous command blocked' if dangerous.any? { |d| command.include?(d) }

  Timeout.timeout(120) do
    stdout, stderr, = Open3.capture3(command, chdir: WORKDIR.to_s)
    out = "#{stdout}#{stderr}".strip
    out.empty? ? '(no output)' : out[0, 50_000]
  end
rescue Timeout::Error
  'Error: Timeout (120s)'
end

def run_read(path, limit = nil)
  lines = safe_path(path).readlines
  lines = lines.first(limit) + ["... (#{lines.size - limit} more lines)\n"] if limit && limit < lines.size
  lines.join[0, 50_000]
rescue StandardError => e
  "Error: #{e.message}"
end

def run_write(path, content)
  fp = safe_path(path)
  fp.dirname.mkpath
  fp.write(content)
  "Wrote #{content.bytesize} bytes to #{path}"
rescue StandardError => e
  "Error: #{e.message}"
end

def run_edit(path, old_text, new_text)
  fp = safe_path(path)
  content = fp.read
  return "Error: Text not found in #{path}" unless content.include?(old_text)

  fp.write(content.sub(old_text, new_text))
  "Edited #{path}"
rescue StandardError => e
  "Error: #{e.message}"
end

# -- Concurrency safety classification --
# Read-only tools can safely run in parallel; mutating tools must be serialized.
CONCURRENCY_SAFE   = %w[read_file].freeze
CONCURRENCY_UNSAFE = %w[write_file edit_file].freeze

# -- The dispatch map: {tool_name => handler} --
TOOL_HANDLERS = {
  'bash' => ->(args) { run_bash(args['command']) },
  'read_file' => ->(args) { run_read(args['path'], args['limit']) },
  'write_file' => ->(args) { run_write(args['path'], args['content']) },
  'edit_file' => ->(args) { run_edit(args['path'], args['old_text'], args['new_text']) }
}.freeze

TOOLS = [
  {
    name: 'bash',
    description: 'Run a shell command.',
    input_schema: {
      type: 'object',
      properties: { command: { type: 'string' } },
      required: ['command']
    }
  },
  {
    name: 'read_file',
    description: 'Read file contents.',
    input_schema: {
      type: 'object',
      properties: { path: { type: 'string' }, limit: { type: 'integer' } },
      required: ['path']
    }
  },
  {
    name: 'write_file',
    description: 'Write content to file.',
    input_schema: {
      type: 'object',
      properties: { path: { type: 'string' }, content: { type: 'string' } },
      required: %w[path content]
    }
  },
  {
    name: 'edit_file',
    description: 'Replace exact text in file.',
    input_schema: {
      type: 'object',
      properties: {
        path: { type: 'string' },
        old_text: { type: 'string' },
        new_text: { type: 'string' }
      },
      required: %w[path old_text new_text]
    }
  }
].freeze

def normalize_messages(messages)
  # Clean up messages before sending to the API.
  # Three jobs:
  # 1. Strip internal metadata fields the API doesn't understand
  # 2. Ensure every tool_use has a matching tool_result (insert placeholder if missing)
  # 3. Merge consecutive same-role messages (API requires strict alternation)

  cleaned = messages.map do |msg|
    content = msg['content']
    cleaned_content = case content
                      when String then content
                      when Array
                        content.filter_map do |block|
                          next unless block.is_a?(Hash)

                          block.reject { |k, _| k.to_s.start_with?('_') }
                        end
                      else
                        content.to_s
                      end

    { 'role' => msg['role'], 'content' => cleaned_content }
  end

  # Collect existing tool_result IDs
  existing_results = Set.new
  cleaned.each do |msg|
    next unless msg['content'].is_a?(Array)

    msg['content'].each do |block|
      next unless block.is_a?(Hash) && block['type'] == 'tool_result'

      existing_results << block['tool_use_id']
    end
  end

  # Find orphaned tool_use blocks and insert placeholder results
  cleaned.each do |msg|
    next unless msg['role'] == 'assistant' && msg['content'].is_a?(Array)

    msg['content'].each do |block|
      next unless block.is_a?(Hash) && block['type'] == 'tool_use' && !existing_results.include?(block['id'])

      cleaned << {
        'role' => 'user',
        'content' => [{ 'type' => 'tool_result', 'tool_use_id' => block['id'], 'content' => '(cancelled)' }]
      }
    end
  end

  # Merge consecutive same-role messages
  return cleaned if cleaned.empty?

  merged = [cleaned.first]
  cleaned[1..].each do |msg|
    if msg['role'] == merged.last['role']
      prev_c = merged.last['content']
      prev_c = [{ 'type' => 'text', 'text' => prev_c.to_s }] unless prev_c.is_a?(Array)
      curr_c = msg['content']
      curr_c = [{ 'type' => 'text', 'text' => curr_c.to_s }] unless curr_c.is_a?(Array)
      merged.last['content'] = prev_c + curr_c
    else
      merged << msg
    end
  end

  merged
end

def agent_loop(messages)
  loop do
    response = CLIENT.messages(
      parameters: {
        model: MODEL,
        system: SYSTEM_PROMPT,
        messages: normalize_messages(messages),
        tools: TOOLS,
        max_tokens: 8000
      }
    )

    messages << { 'role' => 'assistant', 'content' => response['content'] }

    break unless response['stop_reason'] == 'tool_use'

    results = response['content'].filter_map do |block|
      next unless block['type'] == 'tool_use'

      handler = TOOL_HANDLERS[block['name']]
      output = handler ? handler.call(block['input']) : "Unknown tool: #{block['name']}"

      puts "> #{block['name']}:"
      puts output[0, 200]

      { 'type' => 'tool_result', 'tool_use_id' => block['id'], 'content' => output }
    end

    messages << { 'role' => 'user', 'content' => results }
  end
end

if __FILE__ == $PROGRAM_NAME
  history = []

  loop do
    print "\e[36ms02 >> \e[0m"
    query = gets&.chomp
    break if query.nil? || %w[q exit].include?(query.strip.downcase) || query.strip.empty?

    history << { 'role' => 'user', 'content' => query }
    agent_loop(history)

    response_content = history.last['content']
    if response_content.is_a?(Array)
      response_content.each do |block|
        puts block['text'] if block['type'] == 'text'
      end
    end
    puts
  end
end
