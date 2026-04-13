class AgentExecutionJob < ApplicationJob
  queue_as :default

  def perform(task_id)
    task = Task.find(task_id)
    task.update!(status: :running, started_at: Time.current)

    worktrees_base = File.join(task.working_directory, ".worktrees")
    worktree_path = File.join(worktrees_base, "task-#{task.id}")
    FileUtils.mkdir_p(worktrees_base)

    create_worktree(task, worktree_path)
    result = run_claude(task, worktree_path)

    task.update!(status: :completed, result: result, completed_at: Time.current)
  rescue => e
    task&.update!(status: :failed, result: "Error: #{e.message}", completed_at: Time.current)
  end

  private

  def create_worktree(task, worktree_path)
    system(
      "git", "-C", task.working_directory,
      "worktree", "add", worktree_path, "-b", task.branch_name,
      exception: true
    )
  end

  def run_claude(task, worktree_path)
    require "open3"

    stdout, stderr, status = Open3.capture3(
      "claude", "--print",
      "-p", task.description,
      "--output-format", "text",
      "--permission-mode", "bypassPermissions",
      chdir: worktree_path
    )

    raise "Claude exited with status #{status.exitstatus}: #{stderr}" unless status.success?

    stdout
  end
end
