# frozen_string_literal: true

RSpec.describe Fiver::Rabbitmq::Cluster do
  subject(:cluster) { described_class.new }

  let(:url) { nil }

  its(:virtual_hosts) { is_expected.to all(be_a Fiver::Rabbitmq::VirtualHost) }
  its(:virtual_hosts) { is_expected.to_not be_empty }

  context 'without queues' do
    its(:queues) { is_expected.to be_empty }
  end

  context 'with queues' do
    before do
      TestJob.perform_later(1, 2, 'three')
    end

    its(:queues) { is_expected.to_not be_empty }
    its(:queues) { is_expected.to all(be_a Fiver::Rabbitmq::Queue) }
  end
end
