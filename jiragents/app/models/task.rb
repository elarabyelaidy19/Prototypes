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
