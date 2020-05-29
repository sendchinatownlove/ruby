# frozen_string_literal: true

describe EmailManager::PoolDonationReceiptSender, '#call' do
  let(:payment_intent) { create :payment_intent }
  let(:receipt_params) do {
      amount: 5000,
      payment_intent: payment_intent,
      email: 'justin@sendchinatownlove.com'
  }
  end

  it 'should call pool donation email sender methods' do
    sender = class_double("EmailManager::Sender")
                 .as_stubbed_const(:transfer_nested_constants => true)
    expect(sender).to receive(:format_amount).with(amount: 5000).and_return(
        "$50.00"
    )
    expect(sender).to receive(:send_receipt)

    EmailManager::PoolDonationReceiptSender.call(receipt_params)
  end
end
