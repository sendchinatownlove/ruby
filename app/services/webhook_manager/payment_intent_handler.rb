# frozen_string_literal: true

# Creates donation and item with the corresponding payload
module WebhookManager
    class PaymentIntentHandler < BaseService

        def self.parse_line_items(payment_intent, amount)

            line_items = JSON.parse(payment_intent.line_items)

            line_items.each do |item_json|
                amount = item_json['amount']
                seller_id = item_json['seller_id']



            item_amount = line_items[]
            fee_amount = 
            
            return_amount = amount
            campaign = Campaign.find_by_id(payment_intent.campaign_id)
            if(campaign.present?)
                # Apply each fee
                campaign.fees.each do |fee|
                    return_amount -= (amount * fee.multiplier)
                    return_amount -= (fee.flat_cost * 100)
                end
            else
                # Apply the default square processing fee
                return_amount *= 0.9725
                return_amount -= 30
            end
            return_amount.floor
        end
    end
end