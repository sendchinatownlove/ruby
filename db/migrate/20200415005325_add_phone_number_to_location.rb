class AddPhoneNumberToLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :phone_number, :string
  end
end
