class AgentExecutionJob < ApplicationJob
  queue_as :default

  WORKTREE_BASE = "/tmp/jiragents-worktrees"

  def perform(task_id)
    task = Task.find(task_id)
    task.update!(status: :running, started_at: Time.current)

    worktree_path = File.join(WORKTREE_BASE, "task-#{task.id}")
    FileUtils.mkdir_p(WORKTREE_BASE)

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
