class MakeAgentOptionalOnTasks < ActiveRecord::Migration[8.1]
  def change
    change_column_null :tasks, :agent_id, true
  end
end
