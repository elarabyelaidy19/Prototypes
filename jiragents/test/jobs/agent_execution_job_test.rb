require "test_helper"

class AgentExecutionJobTest < ActiveJob::TestCase
  setup do
    @agent = Agent.create!(name: "Sara", description: "Test agent")
    @task = Task.create!(
      title: "Test task",
      description: "Say hello",
      agent: @agent,
      working_directory: "/tmp/jiragents-test-repo"
    )
    # Initialize a bare test git repo
    FileUtils.rm_rf("/tmp/jiragents-test-repo")
    system("git", "init", "/tmp/jiragents-test-repo")
    system("git", "-C", "/tmp/jiragents-test-repo", "config", "user.email", "test@test.com")
    system("git", "-C", "/tmp/jiragents-test-repo", "config", "user.name", "Test")
    system("git", "-C", "/tmp/jiragents-test-repo", "commit", "--allow-empty", "-m", "init")
  end

  teardown do
    FileUtils.rm_rf("/tmp/jiragents-test-repo")
    FileUtils.rm_rf("/tmp/jiragents-worktrees/task-#{@task.id}")
  end

  test "sets task to running on start" do
    AgentExecutionJob.any_instance.stubs(:run_claude).returns("Task completed successfully")
    AgentExecutionJob.perform_now(@task.id)
    @task.reload
    assert_includes ["completed", "running"], @task.status
  end

  test "sets task to completed on success" do
    AgentExecutionJob.any_instance.stubs(:run_claude).returns("Done!")
    AgentExecutionJob.perform_now(@task.id)
    @task.reload
    assert_equal "completed", @task.status
    assert_equal "Done!", @task.result
    assert_not_nil @task.completed_at
  end

  test "sets task to failed on error" do
    AgentExecutionJob.any_instance.stubs(:run_claude).raises(StandardError, "Claude crashed")
    AgentExecutionJob.perform_now(@task.id)
    @task.reload
    assert_equal "failed", @task.status
    assert_includes @task.result, "Claude crashed"
  end

  test "creates a git worktree" do
    AgentExecutionJob.any_instance.stubs(:run_claude).returns("Done")
    AgentExecutionJob.perform_now(@task.id)

    branches = `git -C /tmp/jiragents-test-repo branch`.strip
    assert_includes branches, @task.branch_name
  end
end
