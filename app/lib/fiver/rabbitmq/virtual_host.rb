# frozen_string_literal: true

module Fiver
  module Rabbitmq
    # Manages a connection to a RabbitMQ virtual host with multiple queues.
    class VirtualHost
      attr_reader :name

      def initialize(name = '/', description: nil, cluster: Rabbitmq.cluster, connection: Rabbitmq.connection)
        @name = name
        @description = description
        @connection = connection
        @cluster = cluster
      end

      def queues
        @cluster.queues(virtual_host: @name).map { |queue| Queue.new(queue.name, connection: @connection) }
      end
    end
  end
end
