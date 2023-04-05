Rails.application.routes.draw do
  post '/auth/login', to: 'authentication#login'

  resources :users

  resources :tags

  resources :events do
    resources :attendees
  end

  resources :groups do
    resources :members
  end
end
