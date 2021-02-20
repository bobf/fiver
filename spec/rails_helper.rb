# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/html'
require 'rspec/rails'
require 'advanced_sneakers_activejob'

Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |path| require path }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# RabbitMQ management plugin does not update instantly so we need to slow down tests in order to
# see latest data and have reliable tests.
Fiver::Rabbitmq::Cluster.poll_delay = 1

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:each) do
    connection = Bunny.new(Rails.application.config_for(:rabbitmq)[:url])
    connection.start
    channel = connection.create_channel
    channel.queue('default', durable: true).purge
    channel.queue_delete('default')
    channel.queue_delete('test-queue')
    channel.queue_delete('example-queue')
    connection.stop
  end
end

AdvancedSneakersActiveJob.configure do |config|
  config.sneakers = {
    connection: Bunny.new(Rails.application.config_for(:rabbitmq)[:url]),
    exchange: 'fiver-test',
    handler: AdvancedSneakersActiveJob::Handler
  }
end
