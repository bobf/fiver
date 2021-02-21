# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :fetch_rabbitmq_state

  def fetch_rabbitmq_state
    @virtual_hosts = Fiver::Rabbitmq::Cluster.new.virtual_hosts
    @queues = Fiver::Rabbitmq::Cluster.new.virtual_hosts
  rescue Fiver::Rabbitmq::ConnectionError
    redirect_to '/errors/connection'
  end
end
