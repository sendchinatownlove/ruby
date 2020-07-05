# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fee, type: :model do
  # Association test
  it { should belong_to(:seller) }
end
