class ChangeFeeMultiplierPrecision < ActiveRecord::Migration[6.0]
  def change
    change_column :fees, :multiplier, :decimal, :scale => 4, :precision => 6
  end
end
