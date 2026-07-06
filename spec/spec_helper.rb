# frozen_string_literal: true

unless RUBY_PLATFORM =~ /java/
  require "simplecov"
  SimpleCov.start do
    add_filter "spec"
  end
end

require "bundler"
Bundler.require :default, :development

support_files = File.expand_path("spec/support/**/*.rb")
Dir[support_files].each { |file| require file }

RSpec.configure do |config|
  config.include SpecSupport
end
