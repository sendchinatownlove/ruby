class AddTimestampToRewards < ActiveRecord::Migration[6.0]
  def change
    change_table(:rewards) { |t| t.timestamps }
  end
end
