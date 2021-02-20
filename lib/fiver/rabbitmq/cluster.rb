# frozen_string_literal: true

module Fiver
  module Rabbitmq
    # Interacts with the rabbitmq management plugin to extract information about the cluster.
    class Cluster
      class << self
        attr_accessor :poll_delay
      end

      def initialize(management_url: Rabbitmq.management_url)
        @management_url = management_url
      end

      def virtual_hosts
        get('vhosts').map do |vhost|
          VirtualHost.new(vhost[:name], description: vhost.dig(:metadata, :description))
        end
      end

      def queues(virtual_host: nil)
        connection = Rabbitmq.connection(virtual_host: virtual_host)
        get("queues/#{virtual_host}").map { |queue| Queue.new(queue[:name], connection: connection) }
      end

      private

      def get(resource)
        response(:get, resource)
      end

      def response(verb, resource)
        sleep Cluster.poll_delay unless Cluster.poll_delay.nil?

        request = Faraday.new(url: @management_url)
        request.basic_auth(uri.user, uri.password)
        body = request.public_send(verb, join('/api/', resource)).body
        JSON.parse(body, symbolize_names: true)
      end

      def join(*args)
        args.join('/').gsub(%r{([^:])/+}, '\1/')
      end

      def uri
        URI.parse(@management_url)
      end
    end
  end
end
