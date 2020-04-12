module EmailHelper
  def self.format_sellers_as_list(seller_names:)
    # Sort to make it deterministic
    seller_names = seller_names.sort
    # Pop off the last seller
    last_seller = seller_names.pop

    # If the list is empty, just return that seller
    return last_seller if seller_names.empty?

    sellers = seller_names.inject('') { |names, name| names + "#{name}, " }
    sellers + "and #{last_seller}"
  end
end
