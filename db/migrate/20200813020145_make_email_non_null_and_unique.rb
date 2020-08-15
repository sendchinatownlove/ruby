# frozen_string_literal: true

class MakeEmailNonNullAndUnique < ActiveRecord::Migration[6.0]
  def change
    change_column :contacts, :email, :string, null: false

    remove_index :contacts, :email
    add_index :contacts, :email, unique: true
  end
end
