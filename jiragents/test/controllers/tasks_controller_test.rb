require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agent = Agent.create!(name: "Sara", description: "Test agent")
    @task = Task.create!(
      title: "Fix login bug",
      description: "The login form crashes",
      agent: @agent,
      working_directory: "/tmp/test-repo"
    )
  end

  test "GET /tasks lists all tasks" do
    get tasks_url
    assert_response :success
    assert_select "h1", /Tasks/
  end

  test "GET /tasks filters by status" do
    get tasks_url(status: "pending")
    assert_response :success
  end

  test "GET /tasks filters by agent" do
    get tasks_url(agent_id: @agent.id)
    assert_response :success
  end

  test "GET /tasks/new renders form" do
    get new_task_url
    assert_response :success
    assert_select "form"
  end

  test "GET /tasks/new pre-selects agent from param" do
    get new_task_url(agent_id: @agent.id)
    assert_response :success
  end

  test "POST /tasks creates task and redirects" do
    assert_difference("Task.count", 1) do
      post tasks_url, params: {
        task: {
          title: "Add dark mode",
          description: "Implement dark mode toggle",
          agent_id: @agent.id,
          working_directory: "/tmp/test-repo"
        }
      }
    end
    assert_redirected_to task_url(Task.last)
  end

  test "POST /tasks with invalid data re-renders form" do
    assert_no_difference("Task.count") do
      post tasks_url, params: { task: { title: "", agent_id: @agent.id, working_directory: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "GET /tasks/:id shows task" do
    get task_url(@task)
    assert_response :success
    assert_select "h1", /Fix login bug/
  end
end
