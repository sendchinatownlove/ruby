class AddGiftCardsSecretToSellers < ActiveRecord::Migration[6.0]
  def change
    add_column :sellers, :gift_cards_access_token, :string, null: false, default: ''

    Seller.all.each do |seller|
      seller.update(gift_cards_access_token: SecureRandom.uuid)
    end

    add_index :sellers, :gift_cards_access_token, unique: true
  end
end
