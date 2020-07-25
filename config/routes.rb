# frozen_string_literal: true

# == Route Map
#
#                                Prefix Verb   URI Pattern                                                                              Controller#Action
#                               charges GET    /charges(.:format)                                                                       charges#index
#                                       POST   /charges(.:format)                                                                       charges#create
#                                charge GET    /charges/:id(.:format)                                                                   charges#show
#                                       PATCH  /charges/:id(.:format)                                                                   charges#update
#                                       PUT    /charges/:id(.:format)                                                                   charges#update
#                                       DELETE /charges/:id(.:format)                                                                   charges#destroy
#                            gift_cards GET    /gift_cards(.:format)                                                                    gift_cards#index
#                                       POST   /gift_cards(.:format)                                                                    gift_cards#create
#                             gift_card GET    /gift_cards/:id(.:format)                                                                gift_cards#show
#                                       PATCH  /gift_cards/:id(.:format)                                                                gift_cards#update
#                                       PUT    /gift_cards/:id(.:format)                                                                gift_cards#update
#                                       DELETE /gift_cards/:id(.:format)                                                                gift_cards#destroy
#                      seller_locations GET    /sellers/:seller_id/locations(.:format)                                                  locations#index
#                                       POST   /sellers/:seller_id/locations(.:format)                                                  locations#create
#                       seller_location GET    /sellers/:seller_id/locations/:id(.:format)                                              locations#show
#                                       PATCH  /sellers/:seller_id/locations/:id(.:format)                                              locations#update
#                                       PUT    /sellers/:seller_id/locations/:id(.:format)                                              locations#update
#                                       DELETE /sellers/:seller_id/locations/:id(.:format)                                              locations#destroy
#                     seller_menu_items GET    /sellers/:seller_id/menu_items(.:format)                                                 menu_items#index
#                                       POST   /sellers/:seller_id/menu_items(.:format)                                                 menu_items#create
#                      seller_menu_item GET    /sellers/:seller_id/menu_items/:id(.:format)                                             menu_items#show
#                                       PATCH  /sellers/:seller_id/menu_items/:id(.:format)                                             menu_items#update
#                                       PUT    /sellers/:seller_id/menu_items/:id(.:format)                                             menu_items#update
#                                       DELETE /sellers/:seller_id/menu_items/:id(.:format)                                             menu_items#destroy
#                          seller_items GET    /sellers/:seller_id/items(.:format)                                                      items#index
#                                       POST   /sellers/:seller_id/items(.:format)                                                      items#create
#                           seller_item GET    /sellers/:seller_id/items/:id(.:format)                                                  items#show
#                                       PATCH  /sellers/:seller_id/items/:id(.:format)                                                  items#update
#                                       PUT    /sellers/:seller_id/items/:id(.:format)                                                  items#update
#                                       DELETE /sellers/:seller_id/items/:id(.:format)                                                  items#destroy
#                               sellers GET    /sellers(.:format)                                                                       sellers#index
#                                       POST   /sellers(.:format)                                                                       sellers#create
#                                seller GET    /sellers/:id(.:format)                                                                   sellers#show
#                                       PATCH  /sellers/:id(.:format)                                                                   sellers#update
#                                       PUT    /sellers/:id(.:format)                                                                   sellers#update
#                                       DELETE /sellers/:id(.:format)                                                                   sellers#destroy
#                              webhooks GET    /webhooks(.:format)                                                                      webhooks#index
#                                       POST   /webhooks(.:format)                                                                      webhooks#create
#                               webhook GET    /webhooks/:id(.:format)                                                                  webhooks#show
#                                       PATCH  /webhooks/:id(.:format)                                                                  webhooks#update
#                                       PUT    /webhooks/:id(.:format)                                                                  webhooks#update
#                                       DELETE /webhooks/:id(.:format)                                                                  webhooks#destroy
#         rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                  action_mailbox/ingresses/mandrill/inbound_emails#create
#         rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                  action_mailbox/ingresses/postmark/inbound_emails#create
#            rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                     action_mailbox/ingresses/relay/inbound_emails#create
#         rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                  action_mailbox/ingresses/sendgrid/inbound_emails#create
#          rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                              action_mailbox/ingresses/mailgun/inbound_emails#create
#        rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#index
#                                       POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#create
#         rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#show
#                                       PATCH  /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
#                                       PUT    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
#                                       DELETE /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#destroy
# rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                      rails/conductor/action_mailbox/reroutes#create
#                    rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#             rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#                    rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#             update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#                  rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

Rails.application.routes.draw do
  resources :charges do
  end
  resources :gift_cards do
  end
  resources :sellers do
    resources :locations, :menu_items, :items
    resources :gift_cards, controller: 'seller_gift_cards'
  end
  resources :fees do
  end
  resources :webhooks do
  end
end
