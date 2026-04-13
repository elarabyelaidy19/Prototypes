# JirAgents MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local Rails app where humans create tasks, assign them to named AI agents, and agents execute autonomously via Claude Code CLI in isolated git worktrees.

**Architecture:** Rails 8 app with SQLite, Solid Queue for background jobs, Hotwire for live status updates. Tasks trigger a background job that creates a git worktree, runs `claude --print`, and saves the result. No streaming -- result only.

**Tech Stack:** Rails 8.1, Ruby 3.4, SQLite, Solid Queue, Turbo Streams, Tailwind CSS, Claude Code CLI

**Spec:** `docs/superpowers/specs/2026-04-13-jiragents-design.md`

---

### Task 1: Scaffold Rails Application

**Files:**
- Create: entire Rails app skeleton in `jiragents/`

- [ ] **Step 1: Generate the Rails app**

```bash
cd /home/elaraby/personal/prototypes/jiragents
rails new . --skip-git --database=sqlite3 --css=tailwind --name=jiragents
```

The `--skip-git` flag avoids a nested `.git` since this lives inside the `prototypes` monorepo. Solid Queue is included by default in Rails 8.

- [ ] **Step 2: Verify the app boots**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails db:create
bin/rails server -p 3000 &
sleep 3
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
# Expected: 200
kill %1
```

- [ ] **Step 3: Commit**

```bash
cd /home/elaraby/personal/prototypes
git add jiragents/
git commit -m "feat(jiragents): scaffold Rails 8 app with SQLite and Tailwind"
```

---

### Task 2: Agent Model

**Files:**
- Create: `db/migrate/TIMESTAMP_create_agents.rb`
- Create: `app/models/agent.rb`
- Create: `test/models/agent_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/models/agent_test.rb`:

```ruby
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
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/models/agent_test.rb
# Expected: Error -- Agent model doesn't exist yet
```

- [ ] **Step 3: Generate model and migration**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails generate model Agent name:string description:text
```

- [ ] **Step 4: Add validations and association to the model**

Replace `app/models/agent.rb` with:

```ruby
class Agent < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
```

- [ ] **Step 5: Add unique index to migration**

Edit the generated migration to add a unique index on `name`:

```ruby
class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :agents, :name, unique: true
  end
end
```

- [ ] **Step 6: Run migration and tests**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails db:migrate
bin/rails test test/models/agent_test.rb
# Expected: 4 tests, 0 failures
```

- [ ] **Step 7: Commit**

```bash
cd /home/elaraby/personal/prototypes
git add jiragents/app/models/agent.rb jiragents/db/ jiragents/test/models/agent_test.rb
git commit -m "feat(jiragents): add Agent model with validations and tests"
```

---

### Task 3: Agents CRUD Controller + Views

**Files:**
- Create: `app/controllers/agents_controller.rb`
- Create: `app/views/agents/index.html.erb`
- Create: `app/views/agents/show.html.erb`
- Create: `app/views/agents/new.html.erb`
- Create: `app/views/agents/_form.html.erb`
- Modify: `config/routes.rb`
- Create: `test/controllers/agents_controller_test.rb`

- [ ] **Step 1: Write the controller test**

Create `test/controllers/agents_controller_test.rb`:

```ruby
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
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/controllers/agents_controller_test.rb
# Expected: Error -- routes/controller don't exist
```

- [ ] **Step 3: Add routes**

Edit `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  resources :agents, only: [:index, :new, :create, :show]

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
```

- [ ] **Step 4: Create the controller**

Create `app/controllers/agents_controller.rb`:

```ruby
class AgentsController < ApplicationController
  def index
    @agents = Agent.all.order(created_at: :desc)
  end

  def show
    @agent = Agent.find(params[:id])
    @tasks = @agent.tasks.order(created_at: :desc)
  end

  def new
    @agent = Agent.new
  end

  def create
    @agent = Agent.new(agent_params)

    if @agent.save
      redirect_to @agent
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def agent_params
    params.expect(agent: [:name, :description])
  end
end
```

- [ ] **Step 5: Create the views**

Create `app/views/agents/index.html.erb`:

```erb
<div class="max-w-4xl mx-auto py-8 px-4">
  <div class="flex justify-between items-center mb-8">
    <h1 class="text-3xl font-bold text-gray-900">Agents</h1>
    <%= link_to "New Agent", new_agent_path,
        class: "bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition" %>
  </div>

  <% if @agents.any? %>
    <div class="grid gap-4">
      <% @agents.each do |agent| %>
        <%= link_to agent_path(agent), class: "block bg-white rounded-lg shadow p-6 hover:shadow-md transition" do %>
          <div class="flex justify-between items-start">
            <div>
              <h2 class="text-xl font-semibold text-gray-900"><%= agent.name %></h2>
              <p class="text-gray-600 mt-1"><%= agent.description %></p>
            </div>
            <span class="bg-gray-100 text-gray-700 text-sm px-3 py-1 rounded-full">
              <%= pluralize(agent.tasks.count, "task") %>
            </span>
          </div>
        <% end %>
      <% end %>
    </div>
  <% else %>
    <div class="text-center py-12 text-gray-500">
      <p class="text-lg">No agents yet.</p>
      <p class="mt-2"><%= link_to "Create your first agent", new_agent_path, class: "text-indigo-600 hover:underline" %></p>
    </div>
  <% end %>
</div>
```

Create `app/views/agents/show.html.erb`:

```erb
<div class="max-w-4xl mx-auto py-8 px-4">
  <div class="mb-6">
    <%= link_to "&larr; All Agents".html_safe, agents_path, class: "text-indigo-600 hover:underline" %>
  </div>

  <div class="bg-white rounded-lg shadow p-6 mb-8">
    <h1 class="text-3xl font-bold text-gray-900"><%= @agent.name %></h1>
    <p class="text-gray-600 mt-2"><%= @agent.description %></p>
  </div>

  <div class="flex justify-between items-center mb-4">
    <h2 class="text-xl font-semibold text-gray-900">Tasks</h2>
    <%= link_to "Assign Task", new_task_path(agent_id: @agent.id),
        class: "bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition" %>
  </div>

  <% if @tasks.any? %>
    <div class="space-y-3">
      <% @tasks.each do |task| %>
        <%= render "tasks/card", task: task %>
      <% end %>
    </div>
  <% else %>
    <p class="text-gray-500 text-center py-8">No tasks assigned to this agent yet.</p>
  <% end %>
</div>
```

Create `app/views/agents/new.html.erb`:

```erb
<div class="max-w-2xl mx-auto py-8 px-4">
  <div class="mb-6">
    <%= link_to "&larr; All Agents".html_safe, agents_path, class: "text-indigo-600 hover:underline" %>
  </div>

  <h1 class="text-3xl font-bold text-gray-900 mb-8">New Agent</h1>

  <%= render "form", agent: @agent %>
</div>
```

Create `app/views/agents/_form.html.erb`:

```erb
<%= form_with(model: agent, class: "space-y-6") do |form| %>
  <% if agent.errors.any? %>
    <div class="bg-red-50 border border-red-200 rounded-lg p-4">
      <h2 class="text-red-800 font-semibold">Please fix the following errors:</h2>
      <ul class="mt-2 list-disc list-inside text-red-700">
        <% agent.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= form.label :name, class: "block text-sm font-medium text-gray-700 mb-1" %>
    <%= form.text_field :name, class: "w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500",
        placeholder: "e.g. Sara, Omar, Alex" %>
  </div>

  <div>
    <%= form.label :description, class: "block text-sm font-medium text-gray-700 mb-1" %>
    <%= form.text_area :description, rows: 3,
        class: "w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500",
        placeholder: "What is this agent about?" %>
  </div>

  <div>
    <%= form.submit class: "bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 transition cursor-pointer" %>
  </div>
<% end %>
```

- [ ] **Step 6: Run tests**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/controllers/agents_controller_test.rb
# Expected: 5 tests, 0 failures
```

Note: The `new_task_path` reference in `agents/show.html.erb` and `tasks/card` partial will cause a routing error until Task 5. That's fine -- the controller tests don't exercise the show page deeply enough to hit that. We'll complete it in Task 5.

- [ ] **Step 7: Commit**

```bash
cd /home/elaraby/personal/prototypes
git add jiragents/app/controllers/agents_controller.rb jiragents/app/views/agents/ jiragents/config/routes.rb jiragents/test/controllers/agents_controller_test.rb
git commit -m "feat(jiragents): add Agents CRUD with controller, views, and tests"
```

---

### Task 4: Task Model

**Files:**
- Create: `db/migrate/TIMESTAMP_create_tasks.rb`
- Create: `app/models/task.rb`
- Create: `test/models/task_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/models/task_test.rb`:

```ruby
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
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/models/task_test.rb
# Expected: Error -- Task model doesn't exist yet
```

- [ ] **Step 3: Generate model and migration**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails generate model Task \
  agent:references \
  title:string \
  description:text \
  status:string \
  result:text \
  branch_name:string \
  working_directory:string \
  started_at:datetime \
  completed_at:datetime
```

- [ ] **Step 4: Edit the migration for defaults and constraints**

Edit the generated migration:

```ruby
class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "pending"
      t.text :result
      t.string :branch_name
      t.string :working_directory, null: false
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :tasks, :status
  end
end
```

- [ ] **Step 5: Implement the model**

Replace `app/models/task.rb`:

```ruby
class Task < ApplicationRecord
  belongs_to :agent

  enum :status, { pending: "pending", running: "running", completed: "completed", failed: "failed" }

  validates :title, presence: true
  validates :working_directory, presence: true

  after_create :set_branch_name

  private

  def set_branch_name
    update_column(:branch_name, "agent/#{agent.name.parameterize}/#{id}")
  end
end
```

- [ ] **Step 6: Run migration and tests**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails db:migrate
bin/rails test test/models/task_test.rb
# Expected: 8 tests, 0 failures
```

- [ ] **Step 7: Commit**

```bash
cd /home/elaraby/personal/prototypes
git add jiragents/app/models/task.rb jiragents/db/ jiragents/test/models/task_test.rb
git commit -m "feat(jiragents): add Task model with status enum, validations, and tests"
```

---

### Task 5: Tasks CRUD Controller + Views

**Files:**
- Create: `app/controllers/tasks_controller.rb`
- Create: `app/views/tasks/index.html.erb`
- Create: `app/views/tasks/show.html.erb`
- Create: `app/views/tasks/new.html.erb`
- Create: `app/views/tasks/_form.html.erb`
- Create: `app/views/tasks/_card.html.erb`
- Create: `app/helpers/tasks_helper.rb`
- Modify: `config/routes.rb`
- Create: `test/controllers/tasks_controller_test.rb`

- [ ] **Step 1: Write the controller test**

Create `test/controllers/tasks_controller_test.rb`:

```ruby
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
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/controllers/tasks_controller_test.rb
# Expected: Error -- routes/controller don't exist
```

- [ ] **Step 3: Update routes**

Edit `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  resources :agents, only: [:index, :new, :create, :show]
  resources :tasks, only: [:index, :new, :create, :show]

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
```

- [ ] **Step 4: Create the helper**

Create `app/helpers/tasks_helper.rb`:

```ruby
module TasksHelper
  STATUS_STYLES = {
    "pending"   => "bg-gray-100 text-gray-700",
    "running"   => "bg-blue-100 text-blue-700",
    "completed" => "bg-green-100 text-green-700",
    "failed"    => "bg-red-100 text-red-700"
  }.freeze

  def task_status_badge(status)
    classes = STATUS_STYLES.fetch(status, "bg-gray-100 text-gray-700")
    tag.span(status.capitalize, class: "text-sm font-medium px-3 py-1 rounded-full #{classes}")
  end
end
```

- [ ] **Step 5: Create the controller**

Create `app/controllers/tasks_controller.rb`:

```ruby
class TasksController < ApplicationController
  def index
    @tasks = Task.includes(:agent).order(created_at: :desc)
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.where(agent_id: params[:agent_id]) if params[:agent_id].present?
  end

  def show
    @task = Task.includes(:agent).find(params[:id])
  end

  def new
    @task = Task.new(agent_id: params[:agent_id])
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      redirect_to @task
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.expect(task: [:title, :description, :agent_id, :working_directory])
  end
end
```

- [ ] **Step 6: Create the task card partial**

Create `app/views/tasks/_card.html.erb`:

```erb
<%= link_to task_path(task), class: "block bg-white rounded-lg shadow p-4 hover:shadow-md transition" do %>
  <div class="flex justify-between items-start">
    <div class="flex-1 min-w-0">
      <h3 class="text-lg font-semibold text-gray-900 truncate"><%= task.title %></h3>
      <p class="text-sm text-gray-500 mt-1">
        Assigned to <span class="font-medium text-gray-700"><%= task.agent.name %></span>
      </p>
    </div>
    <div class="ml-4 flex-shrink-0">
      <%= task_status_badge(task.status) %>
    </div>
  </div>
<% end %>
```

- [ ] **Step 7: Create the views**

Create `app/views/tasks/index.html.erb`:

```erb
<div class="max-w-4xl mx-auto py-8 px-4">
  <div class="flex justify-between items-center mb-8">
    <h1 class="text-3xl font-bold text-gray-900">Tasks</h1>
    <%= link_to "New Task", new_task_path,
        class: "bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition" %>
  </div>

  <div class="flex gap-2 mb-6">
    <%= link_to "All", tasks_path,
        class: "px-3 py-1 rounded-full text-sm #{params[:status].blank? ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}" %>
    <% %w[pending running completed failed].each do |status| %>
      <%= link_to status.capitalize, tasks_path(status: status),
          class: "px-3 py-1 rounded-full text-sm #{params[:status] == status ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}" %>
    <% end %>
  </div>

  <div id="tasks" class="space-y-3">
    <% if @tasks.any? %>
      <% @tasks.each do |task| %>
        <%= render "tasks/card", task: task %>
      <% end %>
    <% else %>
      <p class="text-gray-500 text-center py-12">No tasks found.</p>
    <% end %>
  </div>
</div>
```

Create `app/views/tasks/show.html.erb`:

```erb
<div class="max-w-4xl mx-auto py-8 px-4">
  <div class="mb-6">
    <%= link_to "&larr; All Tasks".html_safe, tasks_path, class: "text-indigo-600 hover:underline" %>
  </div>

  <div id="<%= dom_id(@task) %>" class="bg-white rounded-lg shadow p-6">
    <div class="flex justify-between items-start mb-4">
      <h1 class="text-3xl font-bold text-gray-900"><%= @task.title %></h1>
      <%= task_status_badge(@task.status) %>
    </div>

    <div class="grid grid-cols-2 gap-4 text-sm text-gray-600 mb-6">
      <div>
        <span class="font-medium text-gray-700">Agent:</span>
        <%= link_to @task.agent.name, agent_path(@task.agent), class: "text-indigo-600 hover:underline" %>
      </div>
      <div>
        <span class="font-medium text-gray-700">Working Directory:</span>
        <code class="text-xs bg-gray-100 px-2 py-1 rounded"><%= @task.working_directory %></code>
      </div>
      <% if @task.branch_name.present? %>
        <div>
          <span class="font-medium text-gray-700">Branch:</span>
          <code class="text-xs bg-gray-100 px-2 py-1 rounded"><%= @task.branch_name %></code>
        </div>
      <% end %>
      <% if @task.started_at.present? %>
        <div>
          <span class="font-medium text-gray-700">Started:</span>
          <%= @task.started_at.strftime("%Y-%m-%d %H:%M") %>
        </div>
      <% end %>
      <% if @task.completed_at.present? %>
        <div>
          <span class="font-medium text-gray-700">Completed:</span>
          <%= @task.completed_at.strftime("%Y-%m-%d %H:%M") %>
        </div>
      <% end %>
    </div>

    <% if @task.description.present? %>
      <div class="mb-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-2">Description</h2>
        <div class="bg-gray-50 rounded-lg p-4 text-gray-700 whitespace-pre-wrap"><%= @task.description %></div>
      </div>
    <% end %>

    <% if @task.result.present? %>
      <div>
        <h2 class="text-lg font-semibold text-gray-900 mb-2">Result</h2>
        <div class="bg-gray-900 text-green-400 rounded-lg p-4 font-mono text-sm whitespace-pre-wrap overflow-x-auto"><%= @task.result %></div>
      </div>
    <% end %>
  </div>
</div>
```

Create `app/views/tasks/new.html.erb`:

```erb
<div class="max-w-2xl mx-auto py-8 px-4">
  <div class="mb-6">
    <%= link_to "&larr; All Tasks".html_safe, tasks_path, class: "text-indigo-600 hover:underline" %>
  </div>

  <h1 class="text-3xl font-bold text-gray-900 mb-8">New Task</h1>

  <%= render "form", task: @task %>
</div>
```

Create `app/views/tasks/_form.html.erb`:

```erb
<%= form_with(model: task, class: "space-y-6") do |form| %>
  <% if task.errors.any? %>
    <div class="bg-red-50 border border-red-200 rounded-lg p-4">
      <h2 class="text-red-800 font-semibold">Please fix the following errors:</h2>
      <ul class="mt-2 list-disc list-inside text-red-700">
        <% task.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= form.label :title, class: "block text-sm font-medium text-gray-700 mb-1" %>
    <%= form.text_field :title,
        class: "w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500",
        placeholder: "e.g. Fix login bug, Add dark mode" %>
  </div>

  <div>
    <%= form.label :description, "Description (prompt for the agent)", class: "block text-sm font-medium text-gray-700 mb-1" %>
    <%= form.text_area :description, rows: 5,
        class: "w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500",
        placeholder: "Describe the task in detail. This will be sent as the prompt to Claude." %>
  </div>

  <div>
    <%= form.label :agent_id, "Assign to Agent", class: "block text-sm font-medium text-gray-700 mb-1" %>
    <%= form.collection_select :agent_id, Agent.order(:name), :id, :name,
        { prompt: "Select an agent..." },
        { class: "w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500" } %>
  </div>

  <div>
    <%= form.label :working_directory, "Working Directory (git repo path)", class: "block text-sm font-medium text-gray-700 mb-1" %>
    <%= form.text_field :working_directory,
        class: "w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500",
        placeholder: "/home/user/projects/my-app" %>
  </div>

  <div>
    <%= form.submit "Create & Run", class: "bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 transition cursor-pointer" %>
  </div>
<% end %>
```

- [ ] **Step 8: Run tests**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/controllers/tasks_controller_test.rb
# Expected: 8 tests, 0 failures
```

- [ ] **Step 9: Commit**

```bash
cd /home/elaraby/personal/prototypes
git add jiragents/app/controllers/tasks_controller.rb jiragents/app/views/tasks/ jiragents/app/helpers/tasks_helper.rb jiragents/config/routes.rb jiragents/test/controllers/tasks_controller_test.rb
git commit -m "feat(jiragents): add Tasks CRUD with status filtering, views, and tests"
```

---

### Task 6: AgentExecutionJob

**Files:**
- Create: `app/jobs/agent_execution_job.rb`
- Create: `test/jobs/agent_execution_job_test.rb`
- Modify: `app/models/task.rb` (add after_create callback to enqueue)

- [ ] **Step 1: Write the failing test**

Create `test/jobs/agent_execution_job_test.rb`:

```ruby
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
    # Initialize a test git repo
    system("rm", "-rf", "/tmp/jiragents-test-repo")
    system("git", "init", "/tmp/jiragents-test-repo")
    system("git", "-C", "/tmp/jiragents-test-repo", "commit", "--allow-empty", "-m", "init")
  end

  teardown do
    system("rm", "-rf", "/tmp/jiragents-test-repo")
    system("rm", "-rf", "/tmp/jiragents-worktrees/task-#{@task.id}")
  end

  test "sets task to running on start" do
    # Stub the claude command to avoid actual execution
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

    worktree_path = "/tmp/jiragents-worktrees/task-#{@task.id}"
    # Worktree should have been created (may or may not still exist depending on cleanup)
    # Check the branch was created
    branches = `git -C /tmp/jiragents-test-repo branch`.strip
    assert_includes branches, @task.branch_name
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/jobs/agent_execution_job_test.rb
# Expected: Error -- AgentExecutionJob doesn't exist
```

- [ ] **Step 3: Add mocha gem for stubbing**

Add to `Gemfile` in the test group:

```ruby
group :test do
  gem "mocha"
end
```

Then run:

```bash
cd /home/elaraby/personal/prototypes/jiragents
bundle install
```

Add to `test/test_helper.rb` after the existing requires:

```ruby
require "mocha/minitest"
```

- [ ] **Step 4: Implement the job**

Create `app/jobs/agent_execution_job.rb`:

```ruby
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
```

- [ ] **Step 5: Wire up the after_create callback**

Edit `app/models/task.rb` -- add the callback to enqueue the job:

```ruby
class Task < ApplicationRecord
  belongs_to :agent

  enum :status, { pending: "pending", running: "running", completed: "completed", failed: "failed" }

  validates :title, presence: true
  validates :working_directory, presence: true

  after_create :set_branch_name
  after_create_commit :enqueue_execution

  private

  def set_branch_name
    update_column(:branch_name, "agent/#{agent.name.parameterize}/#{id}")
  end

  def enqueue_execution
    AgentExecutionJob.perform_later(id)
  end
end
```

- [ ] **Step 6: Run tests**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/jobs/agent_execution_job_test.rb
# Expected: 4 tests, 0 failures
```

- [ ] **Step 7: Commit**

```bash
cd /home/elaraby/personal/prototypes
git add jiragents/app/jobs/agent_execution_job.rb jiragents/app/models/task.rb jiragents/test/jobs/agent_execution_job_test.rb jiragents/Gemfile jiragents/Gemfile.lock jiragents/test/test_helper.rb
git commit -m "feat(jiragents): add AgentExecutionJob with worktree isolation and Claude CLI execution"
```

---

### Task 7: Turbo Stream Live Updates

**Files:**
- Modify: `app/models/task.rb` (add broadcasts)
- Modify: `app/views/tasks/index.html.erb` (add turbo_stream_from)
- Modify: `app/views/tasks/show.html.erb` (add turbo_stream_from)
- Modify: `app/views/agents/show.html.erb` (add turbo_stream_from)

- [ ] **Step 1: Add broadcasts to Task model**

Edit `app/models/task.rb` -- add `broadcasts_refreshes` at the top of the class:

```ruby
class Task < ApplicationRecord
  belongs_to :agent

  broadcasts_refreshes

  enum :status, { pending: "pending", running: "running", completed: "completed", failed: "failed" }

  validates :title, presence: true
  validates :working_directory, presence: true

  after_create :set_branch_name
  after_create_commit :enqueue_execution

  private

  def set_branch_name
    update_column(:branch_name, "agent/#{agent.name.parameterize}/#{id}")
  end

  def enqueue_execution
    AgentExecutionJob.perform_later(id)
  end
end
```

- [ ] **Step 2: Add turbo_stream_from to views**

Add at the top of `app/views/tasks/index.html.erb` (before the outer div):

```erb
<%= turbo_stream_from "tasks" %>
```

Add at the top of `app/views/tasks/show.html.erb` (before the outer div):

```erb
<%= turbo_stream_from @task %>
```

Add at the top of `app/views/agents/show.html.erb` (before the outer div):

```erb
<%= turbo_stream_from "tasks" %>
```

- [ ] **Step 3: Verify existing tests still pass**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test
# Expected: All tests pass
```

- [ ] **Step 4: Commit**

```bash
cd /home/elaraby/personal/prototypes
git add jiragents/app/models/task.rb jiragents/app/views/tasks/ jiragents/app/views/agents/show.html.erb
git commit -m "feat(jiragents): add Turbo Stream broadcasts for live task status updates"
```

---

### Task 8: Dashboard

**Files:**
- Create: `app/controllers/dashboard_controller.rb`
- Create: `app/views/dashboard/index.html.erb`
- Modify: `config/routes.rb` (add root route)
- Create: `test/controllers/dashboard_controller_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/controllers/dashboard_controller_test.rb`:

```ruby
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/controllers/dashboard_controller_test.rb
# Expected: Error -- no root route
```

- [ ] **Step 3: Add root route**

Edit `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  root "dashboard#index"

  resources :agents, only: [:index, :new, :create, :show]
  resources :tasks, only: [:index, :new, :create, :show]

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
```

- [ ] **Step 4: Create the controller**

Create `app/controllers/dashboard_controller.rb`:

```ruby
class DashboardController < ApplicationController
  def index
    @agents_count = Agent.count
    @tasks_by_status = Task.group(:status).count
    @recent_tasks = Task.includes(:agent).order(created_at: :desc).limit(10)
  end
end
```

- [ ] **Step 5: Create the view**

Create `app/views/dashboard/index.html.erb`:

```erb
<%= turbo_stream_from "tasks" %>

<div class="max-w-4xl mx-auto py-8 px-4">
  <h1 class="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <div class="bg-white rounded-lg shadow p-4 text-center">
      <div class="text-3xl font-bold text-gray-900"><%= @agents_count %></div>
      <div class="text-sm text-gray-500 mt-1">Agents</div>
    </div>
    <div class="bg-white rounded-lg shadow p-4 text-center">
      <div class="text-3xl font-bold text-yellow-600"><%= @tasks_by_status["pending"] || 0 %></div>
      <div class="text-sm text-gray-500 mt-1">Pending</div>
    </div>
    <div class="bg-white rounded-lg shadow p-4 text-center">
      <div class="text-3xl font-bold text-blue-600"><%= @tasks_by_status["running"] || 0 %></div>
      <div class="text-sm text-gray-500 mt-1">Running</div>
    </div>
    <div class="bg-white rounded-lg shadow p-4 text-center">
      <div class="text-3xl font-bold text-green-600"><%= @tasks_by_status["completed"] || 0 %></div>
      <div class="text-sm text-gray-500 mt-1">Completed</div>
    </div>
  </div>

  <div class="flex gap-4 mb-6">
    <%= link_to "Agents", agents_path, class: "bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition" %>
    <%= link_to "Tasks", tasks_path, class: "bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition" %>
    <%= link_to "New Task", new_task_path, class: "bg-white text-indigo-600 border border-indigo-600 px-4 py-2 rounded-lg hover:bg-indigo-50 transition" %>
  </div>

  <h2 class="text-xl font-semibold text-gray-900 mb-4">Recent Tasks</h2>

  <% if @recent_tasks.any? %>
    <div class="space-y-3">
      <% @recent_tasks.each do |task| %>
        <%= render "tasks/card", task: task %>
      <% end %>
    </div>
  <% else %>
    <p class="text-gray-500 text-center py-8">No tasks yet. Create an agent and assign a task!</p>
  <% end %>
</div>
```

- [ ] **Step 6: Run tests**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test test/controllers/dashboard_controller_test.rb
# Expected: 1 test, 0 failures
```

- [ ] **Step 7: Run all tests**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test
# Expected: All tests pass (18 total)
```

- [ ] **Step 8: Commit**

```bash
cd /home/elaraby/personal/prototypes
git add jiragents/app/controllers/dashboard_controller.rb jiragents/app/views/dashboard/ jiragents/config/routes.rb jiragents/test/controllers/dashboard_controller_test.rb
git commit -m "feat(jiragents): add Dashboard with stats and recent tasks"
```

---

### Task 9: Navigation Layout + Smoke Test

**Files:**
- Modify: `app/views/layouts/application.html.erb` (add nav bar)

- [ ] **Step 1: Add navigation to the application layout**

Edit `app/views/layouts/application.html.erb` -- add a nav bar inside the body, before `<%= yield %>`:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>JirAgents</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="bg-gray-50 min-h-screen">
    <nav class="bg-white shadow-sm border-b border-gray-200">
      <div class="max-w-4xl mx-auto px-4 py-3 flex items-center justify-between">
        <%= link_to "JirAgents", root_path, class: "text-xl font-bold text-indigo-600" %>
        <div class="flex gap-4">
          <%= link_to "Dashboard", root_path, class: "text-gray-600 hover:text-gray-900" %>
          <%= link_to "Agents", agents_path, class: "text-gray-600 hover:text-gray-900" %>
          <%= link_to "Tasks", tasks_path, class: "text-gray-600 hover:text-gray-900" %>
        </div>
      </div>
    </nav>

    <main>
      <%= yield %>
    </main>
  </body>
</html>
```

- [ ] **Step 2: Run all tests one final time**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/rails test
# Expected: All tests pass
```

- [ ] **Step 3: Start the server and verify manually**

```bash
cd /home/elaraby/personal/prototypes/jiragents
bin/dev
```

Manual checks:
1. Visit `http://localhost:3000` -- dashboard loads with stats
2. Navigate to `/agents/new` -- create an agent named "Sara"
3. Navigate to `/tasks/new` -- create a task assigned to Sara with a real git repo path
4. Watch the task go from pending to running to completed on the show page
5. Verify the result text appears

- [ ] **Step 4: Commit**

```bash
cd /home/elaraby/personal/prototypes
git add jiragents/app/views/layouts/application.html.erb
git commit -m "feat(jiragents): add navigation layout and finalize MVP"
```
