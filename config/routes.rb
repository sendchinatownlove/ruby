# frozen_string_literal: true

Rails.application.routes.draw do
  resources :charges do
  end
  resources :gift_cards do
  end
  resources :sellers do
    resources :locations, :menu_items
  end
  resources :webhooks do
  end
end
