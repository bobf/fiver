# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :fetch_rabbitmq_state

  def fetch_rabbitmq_state
    @virtual_hosts = cluster.virtual_hosts
    @queues = cluster.queues
  rescue Fiver::Rabbitmq::ConnectionError => e
    redirect_to error_path(error: :connection, message: e.message)
  end

  private

  def cluster
    @cluster ||= Fiver::Rabbitmq::Cluster.new
  end
end
