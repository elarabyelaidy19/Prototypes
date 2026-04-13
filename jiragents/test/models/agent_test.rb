require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "valid with name and description" do
    agent = Agent.new(name: "Sara", description: "Frontend specialist")
    assert agent.valid?
  end

  test "invalid without name" do
    agent = Agent.new(name: nil)
    assert_not agent.valid?
    assert_includes agent.errors[:name], "can't be blank"
  end

  test "name must be unique" do
    Agent.create!(name: "Sara", description: "First")
    duplicate = Agent.new(name: "Sara", description: "Second")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "has many tasks" do
    agent = Agent.create!(name: "Sara", description: "Test")
    assert_respond_to agent, :tasks
  end
end
