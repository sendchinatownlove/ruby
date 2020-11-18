# frozen_string_literal: true

class AddProjectIdToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :project_id, :bigint, null: true
    add_index :campaigns, :project_id
    add_foreign_key :campaigns, :projects
  end
end
