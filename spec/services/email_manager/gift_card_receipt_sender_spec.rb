# frozen_string_literal: true

describe EmailManager::GiftCardReceiptSender, '#call' do
  let(:payment_intent) { create :payment_intent }
  let(:gift_card_detail) { create :gift_card_detail }
  let(:receipt_params) do {
      amount: 5000,
      gift_card_detail: gift_card_detail,
      merchant: "Three Broomsticks",
      payment_intent: payment_intent,
      email: 'justin@sendchinatownlove.com'
  }
  end

  it 'should call gift card donation email sender methods' do
    sender = class_double("EmailManager::Sender")
                 .as_stubbed_const(:transfer_nested_constants => true)
    expect(sender).to receive(:format_amount).with(amount: 5000).and_return(
        "$50.00"
    )
    expect(sender).to receive(:send_receipt)

    EmailManager::GiftCardReceiptSender.call(receipt_params)
  end
end
