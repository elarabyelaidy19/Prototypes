class DashboardController < ApplicationController
  def index
    @agents_count = Agent.count
    @tasks_by_status = Task.group(:status).count
    @recent_tasks = Task.includes(:agent).order(created_at: :desc).limit(10)
  end
end
