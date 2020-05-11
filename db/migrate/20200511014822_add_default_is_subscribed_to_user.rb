class AddDefaultIsSubscribedToUser < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :is_subscribed, from: nil, to: true
    change_column_null :users, :is_subscribed, false
  end
end
