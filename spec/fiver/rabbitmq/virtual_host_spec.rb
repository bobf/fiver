# frozen_string_literal: true

RSpec.describe Fiver::Rabbitmq::VirtualHost do
  subject(:virtual_host) { described_class.new }

  it { is_expected.to be_a described_class }

  context 'with queues' do
    before do
      TestJob.perform_later(1, 2, 'three')
    end

    its(:queues) { is_expected.to all(be_a Fiver::Rabbitmq::Queue) }
    its(:queues) { is_expected.to_not be_empty }
  end

  context 'without queues' do
    its(:queues) { is_expected.to be_empty }
  end
end
