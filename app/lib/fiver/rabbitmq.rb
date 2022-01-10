# frozen_string_literal: true

module Fiver
  # Provides defaults for connectivity to RabbitMQ. Contains classes which abstract various
  # RabbitMQ components.
  module Rabbitmq
    class << self
      def connection(virtual_host: nil)
        return Bunny.new(config(:url)) if virtual_host.nil? || virtual_host == '/'

        Bunny.new("#{config(:url)}/#{virtual_host}")
      end

      def cluster
        Cluster.new(management_url: management_url)
      end

      def management_url
        config(:management_url)
      end

      private

      def config(key)
        Rails.application.config_for(:rabbitmq).fetch(key)
      end
    end
  end
end
