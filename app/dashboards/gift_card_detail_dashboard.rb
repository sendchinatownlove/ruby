require "administrate/base_dashboard"

class GiftCardDetailDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    item: Field::BelongsTo,
    recipient: Field::BelongsTo.with_options(class_name: "Contact"),
    gift_card_amount: Field::HasMany,
    id: Field::Number,
    gift_card_id: Field::String,
    receipt_id: Field::String,
    expiration: Field::Date,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    seller_gift_card_id: Field::String,
    recipient_id: Field::Number,
    single_use: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  item
  recipient
  gift_card_amount
  id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  item
  recipient
  gift_card_amount
  id
  gift_card_id
  receipt_id
  expiration
  created_at
  updated_at
  seller_gift_card_id
  recipient_id
  single_use
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  item
  recipient
  gift_card_amount
  gift_card_id
  receipt_id
  expiration
  seller_gift_card_id
  recipient_id
  single_use
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how gift card details are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(gift_card_detail)
  #   "GiftCardDetail ##{gift_card_detail.id}"
  # end
end
