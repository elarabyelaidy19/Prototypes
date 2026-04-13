class AgentsController < ApplicationController
  def index
    scope = Agent.order(created_at: :desc)
    scope = scope.includes(:tasks) if defined?(Task)
    @agents = scope
  end

  def show
    @agent = Agent.find(params[:id])
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
