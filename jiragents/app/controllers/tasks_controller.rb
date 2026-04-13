class TasksController < ApplicationController
  def index
    @agents = Agent.order(:name)
    @tasks = Task.includes(:agent).order(created_at: :desc)
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.where(agent_id: params[:agent_id]) if params[:agent_id].present?
  end

  def show
    @task = Task.includes(:agent).find(params[:id])
  end

  def new
    @agents = Agent.order(:name)
    @task = Task.new(agent_id: params[:agent_id])
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

  private

  def task_params
    params.expect(task: [:title, :description, :agent_id, :working_directory])
  end
end
