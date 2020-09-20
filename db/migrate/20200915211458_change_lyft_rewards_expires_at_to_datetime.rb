# frozen_string_literal: true

class ChangeLyftRewardsExpiresAtToDatetime < ActiveRecord::Migration[6.0]
  def change
    change_column :lyft_rewards, :expires_at, :datetime
  end
end
