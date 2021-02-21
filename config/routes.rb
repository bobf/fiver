# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'queues#index'

  resources :queues, only: %i[index] do
    resources :jobs, only: %i[index]
  end

  resources :errors, only: %i[show], param: :error
end
