# frozen_string_literal: true

RSpec.describe '/queues' do
  describe 'GET /queues' do
    it 'provides a list of queues' do
      connection = Fiver::Rabbitmq.connection
      connection.start
      connection.create_channel.queue('example-queue', durable: true)
      get '/queues'
      expect(document.div(class: 'row virtual-host')).to contain_text '/ (default) example-queue'
    end
  end

  describe 'GET /queues/:id/jobs' do
    it 'provides a list of messages' do
      connection = Fiver::Rabbitmq.connection
      connection.start
      queue = connection.create_channel.queue('example-queue', durable: true)
      queue.publish(fixture('job.json').read)
      get '/queues/example-queue/jobs'
      expect(document.div(class: 'job-class', text: 'TestJob')).to exist
    end
  end
end
