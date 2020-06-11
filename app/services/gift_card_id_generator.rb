# frozen_string_literal: true

class GiftCardIdGenerator
  class << self
    def generate_gift_card_id
      (1..50).each do |_i|
        potential_id = SecureRandom.uuid
        # Use this ID if it's not already taken
        unless GiftCardDetail.where(gift_card_id: potential_id).present?
          return potential_id
        end
      end
      raise CannotGenerateUniqueHash, 'Error generating unique gift_card_id'
    end

    def generate_seller_gift_card_id(seller_id:)
      (1..50).each do |_i|
        hash = generate_seller_gift_card_id_hash.upcase
        potential_id_prefix = hash[0...3]
        potential_id_suffix = hash[3...5]
        potential_id = "##{potential_id_prefix}-#{potential_id_suffix}"
        # Use this ID if it's not already taken
        return potential_id unless GiftCardDetail.where(
          seller_gift_card_id: potential_id
        ).joins(:item).where(items: { seller_id: seller_id }).present?
      end
      raise CannotGenerateUniqueHash, 'Error generating unique gift_card_id'
    end

    private

    def generate_seller_gift_card_id_hash
      ('a'..'z').to_a.sample(5).join
    end
  end
end
