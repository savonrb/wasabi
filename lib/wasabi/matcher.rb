require "wasabi/matcher/regular"
require "wasabi/matcher/wildcard"

module Wasabi
  module Matcher

    def self.create(matcher)
      wildcard = matcher.end_with?("*")
      wildcard ? Wildcard.new(matcher) : Regular.new(matcher)
    end

  end
end
