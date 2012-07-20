module Wasabi
  class Matcher

    def initialize(matcher)
      @wildcard = matcher.end_with?("*")
      @matcher = parse(matcher)
    end

    def ===(stack)
      @wildcard ? wildcard_compare(stack) : compare(stack)
    end

    private

    def wildcard_compare(stack)
      return false if stack.size < @matcher.size
      size_diff = stack.size - @matcher.size

      @matcher.each_with_index do |nodes, index|
        return false unless nodes.include?(stack[-(size_diff+(index+1))])
      end
      true
    end

    def compare(stack)
      return false if @matcher.size != stack.size

      @matcher.each_with_index do |nodes, index|
        return false unless nodes.include?(stack[-(index+1)])
      end
      true
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
