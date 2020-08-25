# frozen_string_literal: true

class MakeCampaignsValiid < ActiveRecord::Migration[6.0]
  def change
    change_column :campaigns, :valid, :boolean, unique: false, default: true
  end
end
