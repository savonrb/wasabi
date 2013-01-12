module Wasabi
  module Matcher

    def self.create(*matcher)
      wildcard = matcher.first.end_with?("*")
      wildcard ? WildcardMatcher.new(*matcher) : PathMatcher.new(*matcher)
    end

    def parse(matcher)
      matcher.split(" > ").reverse.map { |node|
        if node.include?("|")
          nsids, local = node.split(":")
          nsids = nsids.split("|")
          nsids.map { |nsid| "#{nsid}:#{local}" }
        elsif node == "*"
          nil
        else
          [node]
        end
      }.compact
    end

  end
end

require "wasabi/path_matcher"
require "wasabi/wildcard_matcher"
