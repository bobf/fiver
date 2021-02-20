# frozen_string_literal: true

module Fiver
  # Representation of a job retrieved from a queue.
  class Job
    FETCHABLE_METHODS = %i[
      job_class job_id provider_job_id queue_name priority arguments executions exception_executions
    ].freeze

    def initialize(info, properties, raw_payload)
      @info = info
      @properties = properties
      @raw_payload = raw_payload
    end

    FETCHABLE_METHODS.each do |name|
      define_method name do
        payload&.fetch(name)
      end
    end

    def enqueued_at
      Time.parse(payload.fetch(:enqueued_at))
    end

    def valid?
      !payload.nil?
    end

    private

    def payload
      @payload ||= JSON.parse(@raw_payload, symbolize_names: true)
    rescue JSON::ParserError
      nil
    end
  end
end
