Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :charges do
  end
  resources :gift_cards do
  end
  resources :sellers do
  end
  resources :webhooks do
  end
end
