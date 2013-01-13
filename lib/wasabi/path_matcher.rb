module Wasabi
  class PathMatcher
    include Matcher

    def initialize(*matcher)
      @matcher = matcher.map { |m| parse(m) }
    end

    def ===(stack)
      @matcher.any? { |matcher| match(stack, matcher) }
    end

    private

    def match(stack, matcher)
      return false if matcher.size != stack.size

      matcher.each_with_index do |nodes, index|
        next if nodes.include?(".")
        return false unless nodes.include?(stack[-(index+1)])
      end
      true
    end

  end
end
