# frozen_string_literal: true

# Provides access to active RabbitMQ jobs.
class JobsController < ApplicationController
  def index
    @jobs = queue.jobs
  end

  private

  def queue
    @queue ||= Fiver::Rabbitmq::Queue.new(
      params[:queue_id],
      connection: Fiver::Rabbitmq.connection(virtual_host: params[:virtual_host])
    )
  end
end
