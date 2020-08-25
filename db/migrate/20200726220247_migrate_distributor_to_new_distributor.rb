# frozen_string_literal: true

class MigrateDistributorToNewDistributor < ActiveRecord::Migration[6.0]
  def change
    add_reference :distributors, :contact, index: true
    add_reference :campaigns, :distributor, index: true

    sellers = Seller.all
    sellers.each do |seller|
      contact = Contact.find_by(seller_id: seller.id)

      # If there is a distributor for the Seller, then there was a previous
      # campaign. So far, only 46 Mott and Melonpanna should have had previous
      # campaigns
      next unless contact.present?

      # NB(justintmckibben): Remember to update the end_date of past campaigns
      # to the real end_date
      distributor = Distributor.create contact: contact
      Campaign.create(
        valid: true,
        end_date: Time.now,
        distributor: distributor,
        seller: seller
      )
    end

    remove_column :contacts, :seller_id
  end
end
