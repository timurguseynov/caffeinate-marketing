require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['ADMIN_USERNAME'] && password == ENV['ADMIN_PASSWORD']
  end
  mount Sidekiq::Web => '/sidekiq'

  mount ::Caffeinate::Engine => '/caffeinate'
  devise_for :users, controllers: {
      registrations: 'users/registrations',
      confirmations: 'users/confirmations',
      sessions: 'users/sessions'
  }

  mount Ahoy::Engine => "/yoha"
  resources :campaigns, only: [:index, :show], param: :slug
  resources :campaign_subscriptions, only: [:index, :show, :create, :update, :destroy], param: :token
  resource :profile, only: [:show, :destroy]
  root to: 'root#index'
end
