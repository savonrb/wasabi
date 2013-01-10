require "bundler"
Bundler.require :default, :development

require "support/spec_support"

RSpec.configure do |config|
  config.include SpecSupport
end
