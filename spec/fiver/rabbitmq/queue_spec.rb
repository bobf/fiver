# frozen_string_literal: true

RSpec.describe Fiver::Rabbitmq::Queue do
  subject(:queue) { described_class.new('default', connection: connection) }

  let(:connection) { Bunny.new(Rails.application.config_for(:rabbitmq)[:url]) }

  it { is_expected.to be_a described_class }

  describe '#jobs' do
    subject(:jobs) { queue.jobs }

    before do
      connection.start
      TestJob.perform_later(1, 2, 'three')
    end

    it { is_expected.to all(be_a Fiver::Job) }
    it { is_expected.to_not be_empty }

    context 'with default constructor arguments' do
      let(:queue) { described_class.new }

      it { is_expected.to all(be_a Fiver::Job) }
      it { is_expected.to_not be_empty }
    end
  end
end
