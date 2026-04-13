require "test_helper"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agent = Agent.create!(name: "Sara", description: "Frontend specialist")
  end

  test "GET /agents lists all agents" do
    get agents_url
    assert_response :success
    assert_select "h1", /Agents/
  end

  test "GET /agents/new renders form" do
    get new_agent_url
    assert_response :success
    assert_select "form"
  end

  test "POST /agents creates agent and redirects" do
    assert_difference("Agent.count", 1) do
      post agents_url, params: { agent: { name: "Omar", description: "Backend dev" } }
    end
    assert_redirected_to agent_url(Agent.last)
  end

  test "POST /agents with invalid data re-renders form" do
    assert_no_difference("Agent.count") do
      post agents_url, params: { agent: { name: "", description: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "GET /agents/:id shows agent" do
    get agent_url(@agent)
    assert_response :success
    assert_select "h1", /Sara/
  end
end
