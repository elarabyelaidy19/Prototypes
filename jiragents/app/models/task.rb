class Task < ApplicationRecord
  belongs_to :agent, optional: true

  broadcasts_refreshes

  enum :status, { pending: "pending", running: "running", completed: "completed", failed: "failed" }

  validates :title, presence: true
  validates :working_directory, presence: true

  after_create_commit :start_execution, if: :agent_id?

  def assign_agent!(agent)
    update!(agent: agent, branch_name: "agent/#{agent.name.parameterize}/#{id}")
    AgentExecutionJob.perform_later(id)
  end

  def assigned?
    agent_id.present?
  end

  private

  def start_execution
    update_column(:branch_name, "agent/#{agent.name.parameterize}/#{id}")
    AgentExecutionJob.perform_later(id)
  end
end
