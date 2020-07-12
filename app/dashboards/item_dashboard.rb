require "administrate/base_dashboard"

class ItemDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    seller: Field::BelongsTo,
    payment_intent: Field::BelongsTo,
    gift_card_detail: Field::HasOne,
    donation_detail: Field::HasOne,
    purchaser: Field::BelongsTo.with_options(class_name: "Contact"),
    id: Field::Number,
    item_type: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    refunded: Field::Boolean,
    purchaser_id: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  seller
  payment_intent
  gift_card_detail
  donation_detail
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  seller
  payment_intent
  gift_card_detail
  donation_detail
  purchaser
  id
  item_type
  created_at
  updated_at
  refunded
  purchaser_id
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  seller
  payment_intent
  gift_card_detail
  donation_detail
  purchaser
  item_type
  refunded
  purchaser_id
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

  # Overwrite this method to customize how items are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(item)
  #   "Item ##{item.id}"
  # end
end
