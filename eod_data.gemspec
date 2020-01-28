# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eod_data/version'

Gem::Specification.new do |spec|
  spec.name = 'eod_data'
  spec.version = EODData::VERSION
  spec.authors = ['Joseph Bridgwater-Rowe']
  spec.email = ['joe@westernmilling.com']

  spec.summary = 'EODData Web Service Client'
  spec.homepage = 'https://github.com/westernmilling/eod_data'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dotenv', '2.7.5'
  spec.add_runtime_dependency 'gli', '2.19.0'
  spec.add_runtime_dependency 'savon', '2.12.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'faker', '2.10.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter', '0.4.1'
  spec.add_development_dependency 'rubocop', '0.76.0'
  spec.add_development_dependency 'simplecov', '0.17.1'
  spec.add_development_dependency 'webmock', '3.8.0'
end
