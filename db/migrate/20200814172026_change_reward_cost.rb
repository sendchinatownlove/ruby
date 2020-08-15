class ChangeRewardCost < ActiveRecord::Migration[6.0]
  def change
    change_column_default :sponsor_sellers, :reward_cost, from: nil, to: 3
    change_column_null :sponsor_sellers, :reward_cost, false
  end
end
