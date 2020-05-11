# frozen_string_literal: true

require 'rails_helper'

# Need to specify type since we're using ActiveModel::Validations
describe Validate::ItemQuery, '#valid?', type: :model do
  it 'is valid order' do
    expect(Validate::ItemQuery.new({ order: 'asc' }).valid?).to equal(true)
  end

  it 'is not valid order' do
    expect(Validate::ItemQuery.new({ order: 'foo' }).valid?).to equal(false)
  end

  it 'is valid limit' do
    expect(Validate::ItemQuery.new({ limit: 1 }).valid?).to equal(true)
  end

  it 'is invalid limit' do
    expect(Validate::ItemQuery.new({ limit: 11 }).valid?).to equal(false)
  end

  it 'is invalid limit number' do
    expect(Validate::ItemQuery.new({ limit: 5.5 }).valid?).to equal(false)
  end
end
