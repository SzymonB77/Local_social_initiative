Rails.application.routes.draw do
  post '/auth/login', to: 'authentication#login'

  resources :users

  resources :tags

  resources :events do
    resources :attendees
    resources :event_tags
    resources :photos
  end

  resources :groups do
    resources :members
    resources :group_events
  end
end
