# frozen_string_literal: true

# Provides a uniform way to make an assertion (i.e. expect a truthy outcome) that may need to be
# retried while an asynchronous job takes place (e.g. RabbitMQ management plugin statistics
# refresh).
module AssertAsync
  def assert_async(delay: 2, iterations: 3, &block)
    iterations.times do
      break unless block.call

      sleep delay
    end

    expect(block.call).to be_truthy
  end
end
