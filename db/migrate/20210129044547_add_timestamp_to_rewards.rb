# frozen_string_literal: true

class AddTimestampToRewards < ActiveRecord::Migration[6.0]
  def change
    change_table(:rewards, &:timestamps)
  end
end
