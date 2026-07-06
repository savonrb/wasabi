# frozen_string_literal: true

source "https://rubygems.org"
gemspec

gem "faraday", ENV["FARADAY_VERSION"] || "~> 2.8"
gem "httpi"
gem "rake", "~> 13.0"
gem "rspec", "~> 3.13"
# httpi requires logger but does not declare it. On Ruby 3.5+ logger is no longer
# a default gem, and faraday 1.x does not pull it in (faraday 2.x does), so the
# httpi + faraday ~> 1.0 combination needs it declared here.
gem "logger", require: false

gem "bundler-audit", "~> 0.9.3", require: false
# ruby_audit 3.x requires Ruby >= 3.1. Only the CI audit job needs it.
gem "ruby_audit", "~> 3.1", require: false if RUBY_VERSION >= "3.1.0"
gem "method_profiler", require: false
gem "simplecov", require: false
gem "standard", require: false
