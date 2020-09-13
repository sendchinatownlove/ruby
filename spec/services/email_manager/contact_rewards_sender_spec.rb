# frozen_string_literal: true

describe EmailManager::ContactRewardsSender, '#call' do
  let(:contact_rewards_params) do
    {
      contact_id: 'contact-id',
      email: 'foo@corp.com',
      token: 'token'
    }
  end

  it 'should call contact rewards email sender methods' do
    sender = class_double('EmailManager::Sender')
             .as_stubbed_const(transfer_nested_constants: true)
    expect(sender).to receive(:send_receipt)

    EmailManager::ContactRewardsSender.call(contact_rewards_params)
  end
end
