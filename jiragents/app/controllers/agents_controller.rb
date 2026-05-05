class AgentsController < ApplicationController
  def index
    @agents = Agent.includes(:tasks).order(created_at: :desc)
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
    params.expect(agent: [ :name, :description ])
  end
end
