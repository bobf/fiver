# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Fiver
  # Dashboard tool for a RabbitMQ/Sneakers/ActiveJob queue system.
  class Application < Rails::Application
    config.load_defaults 6.0
  end
end
