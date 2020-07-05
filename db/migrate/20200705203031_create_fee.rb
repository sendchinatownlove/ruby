class CreateFee < ActiveRecord::Migration[6.0]
  def change
    create_table :fees do |t|
      t.decimal :multiplier, default: 0
      t.boolean :active, default: true
    end
  end
end
