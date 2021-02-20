# frozen_string_literal: true

Rails.application.routes.draw do
  resources :queues, only: %i[index] do
    resources :jobs, only: %i[index]
  end
end
