# frozen_string_literal: true

class AddNeighborhoodToCampaign < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :neighborhood, :string

    # Get all of the current campaigns and fill the neighborhood
    Campaign.all.each do |c|
      c.update(neighborhood: c.location.neighborhood)
    end

    change_column :campaigns, :location_id, :bigint, null: true
  end
end
