module Wasabi
  class WildcardMatcher
    include Matcher

    def initialize(*matcher)
      @matcher = matcher.map { |m| parse(m) }
    end

    def ===(stack)
      @matcher.any? { |matcher| match(stack, matcher) }
    end

    private

    def match(stack, matcher)
      return false if stack.size <= matcher.size
      size_diff = stack.size - matcher.size

      matcher.each_with_index do |nodes, index|
        return false unless nodes.include?(stack[-(size_diff+(index+1))])
      end
      true
    end

  end
end
