# frozen_string_literal: true

AdvancedSneakersActiveJob.configure do |config|
  config.sneakers = {
    connection: Bunny.new(Rails.application.config_for(:rabbitmq)[:url]),
    exchange: 'fiver-test',
    handler: AdvancedSneakersActiveJob::Handler
  }
end

class DemoJob < ApplicationJob
  def perform
    puts 'Running demo job.'
  end
end

Rails.application.configure do
  config.active_job.queue_adapter = :advanced_sneakers
end

DemoJob.perform_later
DemoJob.perform_later
DemoJob.perform_later
DemoJob.perform_later
