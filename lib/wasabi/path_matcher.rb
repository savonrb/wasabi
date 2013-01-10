module Wasabi
  class PathMatcher
    include Matcher

    def initialize(matcher)
      @matcher = parse(matcher)
    end

    def ===(stack)
      return false if @matcher.size != stack.size

      @matcher.each_with_index do |nodes, index|
        return false unless nodes.include?(stack[-(index+1)])
      end
      true
    end

  end
end
