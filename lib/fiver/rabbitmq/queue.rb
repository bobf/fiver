# frozen_string_literal: true

module Fiver
  module Rabbitmq
    # Provides access to messages within a RabbitMQ queue.
    class Queue
      attr_reader :name

      def initialize(name = 'default', connection: Rabbitmq.connection)
        @name = name
        connection.start unless connection.open?
        @connection = connection
      end

      def messages
        channel = @connection.create_channel
        queue = channel.queue(@name, durable: true)
        messages = []
        loop do
          message = queue.pop(manual_ack: true)
          break if message.all?(&:nil?)

          messages << Job.new(*message)
        end
        channel.close
        messages
      end
    end
  end
end
