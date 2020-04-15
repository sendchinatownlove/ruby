class AddPhoneNumberToSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sellers, :phone_number, :string
  end
end
