# frozen_string_literal: true

class AddNonprofitIdToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_reference :campaigns, :nonprofit, index: true
  end
end
