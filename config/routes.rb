Rails.application.routes.draw do
  resources :charges do
  end
  resources :gift_cards do
  end
  resources :sellers do
    resources :addresses
  end
  resources :webhooks do
  end
end
