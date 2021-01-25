# frozen_string_literal: true

describe EmailManager::MagicLinkSender, '#call' do
  let(:magic_link_params) do
    {
      email: 'foo@corp.com',
      magic_link_url: 'https://auth.workos.com/passwordless/id/configm'
    }
  end

  it 'should call magic link email sender methods' do
    sender = class_double('EmailManager::Sender')
             .as_stubbed_const(transfer_nested_constants: true)
    expect(sender).to receive(:send_receipt)

    EmailManager::MagicLinkSender.call(magic_link_params)
  end
end
