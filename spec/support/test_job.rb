# frozen_string_literal: true

class TestJob < ActiveJob::Base
  def perform
    puts 'performing job'
  end
end
