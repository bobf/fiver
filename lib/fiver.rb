# frozen_string_literal: true

require 'json'

require 'fiver/version'
require 'fiver/rabbitmq'
require 'fiver/job'

module Fiver
  class Error < StandardError; end

  module Rabbitmq
    class Error < Fiver::Error; end

    class ConnectionError < Error; end
  end
end
