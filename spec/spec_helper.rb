# frozen_string_literal: true

require 'bundler/setup'
require 'faker'
require 'simplecov'
require 'webmock/rspec'

SimpleCov.start

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = '.rspec_status'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
