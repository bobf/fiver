# frozen_string_literal: true

require_relative 'lib/fiver/version'

Gem::Specification.new do |spec|
  spec.name          = 'fiver'
  spec.version       = Fiver::VERSION
  spec.authors       = ['Bob Farrell']
  spec.email         = ['git@bob.frl']

  spec.summary       = 'Sneakers/ActiveJob/RabbitMQ dashboard'
  spec.description   = 'Monitor and manage jobs in a live Sneakers/ActiveJob queue system'
  spec.homepage      = 'https://github.com/bobf/fiver'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']
end
