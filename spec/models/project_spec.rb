# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                 :bigint           not null, primary key
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  square_location_id :string           not null
#
require 'rails_helper'

RSpec.describe Project, type: :model do
  it { should validate_presence_of(:square_location_id) }

  let!(:project) do
    create(:project)
  end

  let(:line_items) do
    [
      {
        amount: 6000,
        currency: 'usd',
        item_type: 'donation',
        quantity: 1,
        project_id: project.id,
        seller_id: seller_id,
        is_distribution: is_distribution
      }
    ]
  end

  describe '#amount_raised' do
    before do
        create(:payment_intent, :with_project, :with_line_items, successful: true)
        create(:payment_intent, :with_project, :with_line_items, successful: true)
        create(:payment_intent, :with_project, :with_line_items, successful: false)
        create(:payment_intent, :with_line_items, successful: true)
    end

    context 'with no payment intents' do
      it 'should return zero as amount_raised' do
        expect(project.amount_raised).to eq 0
      end
    end

    context 'with successful payment intents' do
      before do
        create(:payment_intent, :with_line_items, project: project, successful: true)
        create(:payment_intent, :with_line_items, project: project, successful: true)
      end
      it 'should return amount' do
        expect(project.amount_raised).to eq 1200
      end
    end

    context 'with no successful payment intents' do
      before do
        create(:payment_intent, :with_line_items, project: project, successful: false)
      end

      it 'should return zero as amount_raised' do
        expect(project.amount_raised).to eq 0
      end
    end
  end
end
