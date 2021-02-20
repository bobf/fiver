# frozen_string_literal: true

# Provides access to active RabbitMQ queues.
class QueuesController < ApplicationController
  def index
    @virtual_hosts = Fiver::Rabbitmq::Cluster.new.virtual_hosts
  end
end
