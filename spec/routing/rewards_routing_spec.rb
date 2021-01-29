require "rails_helper"

RSpec.describe RewardsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/rewards").to route_to("rewards#index")
    end
  end
end
