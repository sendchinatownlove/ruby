require "administrate/base_dashboard"

class PaymentIntentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    items: Field::HasMany,
    purchaser: Field::BelongsTo.with_options(class_name: "Contact"),
    recipient: Field::BelongsTo.with_options(class_name: "Contact"),
    id: Field::Number,
    line_items: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    successful: Field::Boolean,
    square_payment_id: Field::String,
    square_location_id: Field::String,
    receipt_url: Field::String,
    purchaser_id: Field::Number,
    recipient_id: Field::Number,
    lock_version: Field::Number,
    fee_id: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  items
  purchaser
  recipient
  id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  items
  purchaser
  recipient
  id
  line_items
  created_at
  updated_at
  successful
  square_payment_id
  square_location_id
  receipt_url
  purchaser_id
  recipient_id
  lock_version
  fee_id
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  items
  purchaser
  recipient
  line_items
  successful
  square_payment_id
  square_location_id
  receipt_url
  purchaser_id
  recipient_id
  lock_version
  fee_id
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

  # Overwrite this method to customize how payment intents are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(payment_intent)
  #   "PaymentIntent ##{payment_intent.id}"
  # end
end
