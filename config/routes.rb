# frozen_string_literal: true

require 'api_constraints'

Rails.application.routes.draw do
  root to: 'home#index', via: :all

  # API
  namespace :api, defaults: { format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :sessions, only: :create
      resource :session, only: :destroy

      post 'search', to: 'restaurants#search'
      post 'preference', to: 'restaurants#preference'
    end
  end
end
