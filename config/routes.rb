Rails.application.routes.draw do
  # root 'welcome#index'
  resources :show

  get '/subscription/show', to: 'subscription#show'
  get '/subscription/add', to: 'subscription#add'
  get '/user/registration', to: 'user#registration'
  get 'user/recovery', to: 'user#recovery'

  mount API::Root => '/'
  mount GrapeSwaggerRails::Engine => '/apidoc'
end
