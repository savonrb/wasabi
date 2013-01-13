module Wasabi
  module Matcher

    def self.create(*matcher)
      case
        when matcher.first.end_with?("*")
          WildcardMatcher.new(*matcher)
        else
          PathMatcher.new(*matcher)
      end
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
