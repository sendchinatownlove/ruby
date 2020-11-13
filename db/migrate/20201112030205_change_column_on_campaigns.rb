# frozen_string_literal: true

class ChangeColumnOnCampaigns < ActiveRecord::Migration[6.0]
  def change
    change_column :campaigns, :price_per_meal, :integer, null: true
  end
end
