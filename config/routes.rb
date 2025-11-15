Rails.application.routes.draw do
  get '/up', to: ->(env) { [200, {}, ['OK']] }
  devise_for :users
  resources :users
  root to: 'users#index'
end
