# frozen_string_literal: true

module Fiver
  module Rabbitmq
    # Interacts with the rabbitmq management plugin to extract information about the cluster.
    class Cluster
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
        path = virtual_host.nil? ? 'queues' : "queues/#{virtual_host}"
        get(path).map { |queue| Queue.new(queue[:name], connection: connection) }
      end

      private

      def get(resource)
        response(:get, resource)
      end

      def response(verb, resource)
        request = Faraday.new(url: @management_url)
        request.basic_auth(uri.user, uri.password)
        body = request.public_send(verb, join('/api/', resource)).body
        JSON.parse(body, symbolize_names: true)
      rescue Faraday::ConnectionFailed
        raise ConnectionError, censored_uri
      end

      def join(*args)
        args.join('/').gsub(%r{([^:])/+}, '\1/')
      end

      def uri
        URI.parse(@management_url)
      end

      def censored_uri
        uri.dup.tap do |object|
          object.user = '*******' unless object.user.nil?
          object.password = '*******' unless object.user.nil?
        end.to_s
      end
    end
  end
end
