# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

gem 'simplecov',       :require => false
gem 'method_profiler', :require => false
gem 'coveralls',       :require => false

if RUBY_VERSION >= '2.4'
  gem 'rubocop-packaging', :require => false
end

platform :rbx do
  gem 'json'
  gem 'racc'
  gem 'rubysl'
  gem 'rubinius-coverage'
end
