require "administrate/base_dashboard"

class SellerDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    translations: Field::HasMany.with_options(class_name: "Seller::Translation"),
    locations: Field::HasMany,
    menu_items: Field::HasMany,
    delivery_options: Field::HasMany,
    items: Field::HasMany,
    fees: Field::HasMany,
    distributor: Field::HasOne,
    id: Field::Number,
    seller_id: Field::String,
    cuisine_name: Field::String,
    accept_donations: Field::Boolean,
    sell_gift_cards: Field::Boolean,
    owner_image_url: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    target_amount: Field::Number,
    hero_image_url: Field::String,
    progress_bar_color: Field::String,
    num_employees: Field::Number,
    founded_year: Field::Number,
    website_url: Field::String,
    menu_url: Field::String,
    square_location_id: Field::String,
    cost_per_meal: Field::Number,
    gallery_image_urls: Field::String,
    logo_image_url: Field::String,
    non_profit_location_id: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  translations
  locations
  menu_items
  delivery_options
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  translations
  locations
  menu_items
  delivery_options
  items
  fees
  distributor
  id
  seller_id
  cuisine_name
  accept_donations
  sell_gift_cards
  owner_image_url
  created_at
  updated_at
  target_amount
  hero_image_url
  progress_bar_color
  num_employees
  founded_year
  website_url
  menu_url
  square_location_id
  cost_per_meal
  gallery_image_urls
  logo_image_url
  non_profit_location_id
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  translations
  locations
  menu_items
  delivery_options
  items
  fees
  distributor
  seller_id
  cuisine_name
  accept_donations
  sell_gift_cards
  owner_image_url
  target_amount
  hero_image_url
  progress_bar_color
  num_employees
  founded_year
  website_url
  menu_url
  square_location_id
  cost_per_meal
  gallery_image_urls
  logo_image_url
  non_profit_location_id
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

  # Overwrite this method to customize how sellers are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(seller)
  #   "Seller ##{seller.id}"
  # end
end
