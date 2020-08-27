# frozen_string_literal: true

require "bundler"
Bundler.require :default, :development

unless RUBY_PLATFORM =~ /java/
  require "simplecov"
  require "coveralls"
  Coveralls.wear!
end

support_files = File.expand_path("spec/support/**/*.rb")
Dir[support_files].each { |file| require file }

RSpec.configure do |config|
  config.include SpecSupport
end
