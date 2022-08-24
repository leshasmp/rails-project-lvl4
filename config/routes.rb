# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: 'web' do
    root 'home#index'

    post 'auth/:provider', to: 'auth#request', as: :auth_request
    get 'auth/:provider/callback', to: 'auth#callback', as: :callback_auth
    delete 'auth/logout', to: 'auth#log_out', as: :auth_logout

    resources :repositories, only: %i[index new create show] do
      scope module: 'repositories' do
        resources :checks, only: %i[create show]
      end
    end
  end

  namespace :api do
    resources :checks, only: :create
  end
end
