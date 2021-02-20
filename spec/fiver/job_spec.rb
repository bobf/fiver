# frozen_string_literal: true

RSpec.describe Fiver::Job do
  subject(:job) { described_class.new(info, properties, payload) }

  let(:info) { nil }
  let(:properties) { nil }
  let(:payload) do
    {
      'job_class' => 'TestJob',
      'job_id' => '14b0c2c2-ff02-481d-b905-a36f858bde0d',
      'provider_job_id' => nil,
      'queue_name' => 'default',
      'priority' => nil,
      'arguments' => [],
      'executions' => 0,
      'exception_executions' => {},
      'locale' => 'en',
      'timezone' => 'UTC',
      'enqueued_at' => '2021-02-20T12:44:12Z'
    }.to_json
  end

  its(:job_class) { is_expected.to eql 'TestJob' }
  its(:job_id) { is_expected.to eql '14b0c2c2-ff02-481d-b905-a36f858bde0d' }
  its(:provider_job_id) { is_expected.to be_nil }
  its(:queue_name) { is_expected.to eql 'default' }
  its(:priority) { is_expected.to eql nil }
  its(:arguments) { is_expected.to eql [] }
  its(:executions) { is_expected.to eql 0 }
  its(:exception_executions) { is_expected.to eql({}) }
  its(:enqueued_at) { is_expected.to eql Time.parse('2021-02-20T12:44:12Z') }
  its(:valid?) { is_expected.to eql true }

  context 'invalid json' do
    let(:payload) { ')not+json(' }

    its(:valid?) { is_expected.to eql false }
    its(:job_class) { is_expected.to be_nil }
  end
end
