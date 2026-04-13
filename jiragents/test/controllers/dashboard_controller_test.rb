require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders dashboard with stats" do
    agent = Agent.create!(name: "Sara", description: "Test")
    Task.create!(title: "T1", description: "d", agent: agent, working_directory: "/tmp")
    Task.create!(title: "T2", description: "d", agent: agent, working_directory: "/tmp")

    get root_url
    assert_response :success
    assert_select "h1", /Dashboard/
  end
end
