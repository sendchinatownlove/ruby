# frozen_string_literal: true

describe EmailManager::MegaGamReceiptSender, '#call' do
  let(:payment_intent) { create :payment_intent }
  let(:receipt_params) do
    {
      amount: 5000,
      campaign_name: 'December Mega GAM',
      payment_intent: payment_intent
    }
  end

  it 'should call mega gam email sender methods' do
    sender = class_double('EmailManager::Sender')
             .as_stubbed_const(transfer_nested_constants: true)
    expect(sender).to receive(:format_amount).with(amount: 5000).and_return(
      '$50.00'
    )
    expect(sender).to receive(:send_receipt)

    EmailManager::MegaGamReceiptSender.call(receipt_params)
  end
end
