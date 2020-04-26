# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  it { should belong_to(:seller) }
end
