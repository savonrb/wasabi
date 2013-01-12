require "bundler"
Bundler.setup(:default, :development)

require "wasabi"
require "rspec"

require "support/spec_support"

RSpec.configure do |config|
  config.include SpecSupport
  config.order = "random"
end
