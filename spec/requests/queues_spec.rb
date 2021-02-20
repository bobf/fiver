# frozen_string_literal: true

RSpec.describe '/queues' do
  describe 'GET /queues' do
    it 'provides a list of queues' do
      connection = Fiver::Rabbitmq.connection
      connection.start
      connection.create_channel.queue('example-queue', durable: true)
      get '/queues'
      expect(document.td(class: 'queue-name', text: 'example-queue')).to exist
    end
  end

  describe 'GET /queues/:id/jobs' do
    it 'provides a list of messages' do
      connection = Fiver::Rabbitmq.connection
      connection.start
      queue = connection.create_channel.queue('example-queue', durable: true)
      queue.publish({ 'job_class' => 'TestJob' }.to_json)
      get '/queues/example-queue/jobs'
      expect(document.td(class: 'job-class', text: 'TestJob')).to exist
    end
  end
end
