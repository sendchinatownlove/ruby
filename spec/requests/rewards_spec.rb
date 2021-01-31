# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/rewards', type: :request do
  describe 'GET /index' do
    it 'renders a successful response' do
      create :reward
      get rewards_url, as: :json
      expect(response).to be_successful
    end
  end
end
