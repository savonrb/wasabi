# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wasabi/version"

Gem::Specification.new do |s|
  s.name        = "wasabi"
  s.version     = Wasabi::VERSION
  s.authors     = ["Daniel Harrington"]
  s.email       = ["me@rubiii.com"]
  s.homepage    = "https://github.com/savonrb/#{s.name}"
  s.summary     = "A simple WSDL parser"
  s.description = s.summary
  s.required_ruby_version = '>= 1.9.2'

  s.license = 'MIT'

  s.add_dependency "httpi",    "~> 2.0"
  s.add_dependency "nokogiri", ">= 1.4.2"
  s.add_dependency "addressable"

  s.files         = Dir["lib/**/*", "CHANGELOG.md", "LICENSE", "README.md"]
  s.require_paths = ["lib"]
  s.metadata = {
    "changelog_uri" =>
      "https://github.com/savonrb/wasabi/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/wasabi/#{s.version}",
    "source_code_uri" => "https://github.com/savonrb/wasabi",
    "bug_tracker_uri" => "https://github.com/savonrb/wasabi/issues",
  }
end
