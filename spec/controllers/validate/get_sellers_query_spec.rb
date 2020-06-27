# frozen_string_literal: true

require 'rails_helper'

# Need to specify type since we're using ActiveModel::Validations
describe Validate::GetSellersQuery, '#valid?', type: :model do
  it 'is valid query with empty params' do
    query = Validate::GetSellersQuery.new({})
    expect(query.valid?).to eq(true)
    expect(query.sort_key).to eq('created_at')
    expect(query.sort_order).to eq('desc')
  end

  it 'is valid query with only sort key' do
    query = Validate::GetSellersQuery.new({ sort: 'created_at' })
    expect(query.valid?).to eq(true)
    expect(query.sort_key).to eq('created_at')
    expect(query.sort_order).to eq('desc')
  end

  it 'is valid query with both sort key and order desc' do
    query = Validate::GetSellersQuery.new({ sort: 'created_at:desc' })
    expect(query.valid?).to eq(true)
    expect(query.sort_key).to eq('created_at')
    expect(query.sort_order).to eq('desc')
  end

  it 'is valid query with both sort key and order asc' do
    query = Validate::GetSellersQuery.new({ sort: 'created_at:asc' })
    expect(query.valid?).to eq(true)
    expect(query.sort_key).to eq('created_at')
    expect(query.sort_order).to eq('asc')
  end

  it 'is not valid query with empty string' do
    query = Validate::GetSellersQuery.new({ sort: '' })
    expect(query.valid?).to eq(false)
  end

  it 'is not valid query with wrong sort key' do
    query = Validate::GetSellersQuery.new({ sort: 'foo' })
    expect(query.valid?).to eq(false)
  end

  it 'is not valid query with wrong sort key and order' do
    query = Validate::GetSellersQuery.new({ sort: 'foo.bar' })
    expect(query.valid?).to eq(false)
  end
end
