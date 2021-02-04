# frozen_string_literal: true

class RewardsController < ApplicationController
  # GET /rewards
  def index
    @rewards = Reward.all

    json_response(@rewards)
  end
end
