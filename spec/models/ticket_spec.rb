# frozen_string_literal: true

# == Schema Information
#
# Table name: tickets
#
#  id                      :bigint           not null, primary key
#  expiration              :date
#  redeemed_at             :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  contact_id              :bigint           not null
#  participating_seller_id :bigint           not null
#  sponsor_seller_id       :bigint
#  ticket_id               :string           not null
#
# Indexes
#
#  index_tickets_on_contact_id               (contact_id)
#  index_tickets_on_participating_seller_id  (participating_seller_id)
#  index_tickets_on_sponsor_seller_id        (sponsor_seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (participating_seller_id => participating_sellers.id)
#  fk_rails_...  (sponsor_seller_id => sponsor_sellers.id)
#
require 'rails_helper'

RSpec.describe Ticket, type: :model do
  # Association tests
  it { should belong_to(:contact) }
  it { should belong_to(:participating_seller) }

  # Uniqueness and presence test for ticket_id
  before { create :ticket }
  it { should validate_uniqueness_of(:ticket_id) }
  it { should validate_presence_of(:ticket_id) }

  # Creation tests
  let(:participating_seller1) { create :participating_seller }
  let(:sponsor_seller1) { create :sponsor_seller }
  let(:contact1) { create :contact }
  let(:contact2) { create :contact }

  let(:ticket1) do
    create(
      :ticket,
      ticket_id: ticket_id1,
      contact: contact1
    )
  end
  let(:ticket2) do
    create(
      :ticket,
      ticket_id: ticket_id2,
      contact: contact2,
      participating_seller: participating_seller1,
      sponsor_seller: sponsor_seller1
    )
  end

  context 'with unique ticket_id' do
    let(:ticket_id1) { 'AEIO-1' }
    let(:ticket_id2) { 'ASDF-2' }

    it 'sucessfully creates' do
      expect(ticket1.ticket_id).to eq(ticket_id1)
      expect(ticket2.ticket_id).to eq(ticket_id2)
    end
  end

  context 'when ticket_id is taken' do
    let(:ticket_id1) { 'ID123' }
    let(:ticket_id2) { 'ID123' }

    it 'raises an error' do
      ticket1
      expect do
        ticket2
      end.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: Ticket has already been taken'
      )
    end
  end
end
