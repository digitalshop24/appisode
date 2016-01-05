GoogleAuthExample::Application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  resources :users
  get 'users/auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  resources :sessions, only: [:create, :destroy]
  resource :home

  root to: "home#show"
  resource :series
  resources :subscriptions

  mount API::Root => '/'
  mount GrapeSwaggerRails::Engine => '/apidoc'
end
