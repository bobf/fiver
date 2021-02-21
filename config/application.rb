# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

$LOAD_PATH.insert(0, File.expand_path(File.join(__dir__, '..', 'lib')))

require 'fiver'

Bundler.require(*Rails.groups)

module Fiver
  # Dashboard tool for a RabbitMQ/Sneakers/ActiveJob queue system.
  class Application < Rails::Application
    config.load_defaults 6.0
    config.autoload_paths << config.root.join('lib')
  end
end
