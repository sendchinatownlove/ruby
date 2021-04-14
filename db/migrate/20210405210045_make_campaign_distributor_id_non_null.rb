# frozen_string_literal: true

class MakeCampaignDistributorIdNonNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :campaigns, :distributor_id, false
  end
end
