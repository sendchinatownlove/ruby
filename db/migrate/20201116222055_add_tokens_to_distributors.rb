class AddTokensToDistributors < ActiveRecord::Migration[6.0]
  def change
    add_column :distributors, :gift_card_login_token, :string
    add_column :distributors, :gift_card_login_expires_at, :datetime
    add_column :distributors, :gift_card_login_state, :string, default: 'new', null: false
  end
end
