class TasksController < ApplicationController
  def index
    @agents = Agent.order(:name)
    @tasks_by_status = Task.group(:status).count
    @tasks = Task.includes(:agent).order(created_at: :desc)
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.where(agent_id: params[:agent_id]) if params[:agent_id].present?
  end

  def show
    @task = Task.includes(:agent).find(params[:id])
    @agents = Agent.order(:name) unless @task.assigned?
  end

  def new
    @agents = Agent.order(:name)
    @task = Task.new(agent_id: params[:agent_id], working_directory: Rails.root.to_s)
  end

  def create
    @agents = Agent.order(:name)
    @task = Task.new(task_params)

    if @task.save
      redirect_to @task
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @task = Task.find(params[:id])

    if @task.assigned?
      redirect_to @task
      return
    end

    if params[:task][:agent_id].blank?
      redirect_to @task, alert: "Please select an agent"
      return
    end

    @task.assign_agent!(Agent.find(params[:task][:agent_id]))
    redirect_to @task
  end

  private

  def task_params
    params.expect(task: [ :title, :description, :agent_id, :working_directory ])
  end
end
