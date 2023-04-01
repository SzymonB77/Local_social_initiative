Rails.application.routes.draw do
  post '/auth/login', to: 'authentication#login'

  resources :users

  resources :events do
    resources :attendees
  end
  resources :groups
end
