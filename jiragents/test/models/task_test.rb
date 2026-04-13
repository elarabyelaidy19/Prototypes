require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @agent = Agent.create!(name: "Sara", description: "Test agent")
  end

  test "valid with all required fields" do
    task = Task.new(
      title: "Fix login bug",
      description: "The login form crashes on empty email",
      agent: @agent,
      working_directory: "/tmp/test-repo"
    )
    assert task.valid?
  end

  test "invalid without title" do
    task = Task.new(title: nil, agent: @agent)
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "invalid without agent" do
    task = Task.new(title: "Fix bug", agent: nil)
    assert_not task.valid?
    assert_includes task.errors[:agent], "must exist"
  end

  test "invalid without working_directory" do
    task = Task.new(title: "Fix bug", agent: @agent, working_directory: nil)
    assert_not task.valid?
    assert_includes task.errors[:working_directory], "can't be blank"
  end

  test "defaults to pending status" do
    task = Task.create!(
      title: "Fix bug",
      description: "Details",
      agent: @agent,
      working_directory: "/tmp/test-repo"
    )
    assert_equal "pending", task.status
  end

  test "status enum values" do
    task = Task.create!(title: "Fix bug", description: "d", agent: @agent, working_directory: "/tmp")
    assert task.pending?

    task.update!(status: :running, started_at: Time.current)
    assert task.running?

    task.update!(status: :completed, completed_at: Time.current, result: "Done")
    assert task.completed?
  end

  test "belongs to agent" do
    task = Task.create!(title: "Fix bug", description: "d", agent: @agent, working_directory: "/tmp")
    assert_equal @agent, task.agent
  end

  test "branch_name is generated before creation" do
    task = Task.create!(title: "Fix bug", description: "d", agent: @agent, working_directory: "/tmp")
    assert_equal "agent/sara/#{task.id}", task.branch_name
  end
end
