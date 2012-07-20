module Wasabi
  class Matcher

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

    private

    def parse(matcher)
      nodes = matcher.split(" > ").reverse
      nodes.map { |node|
        if node.include?("|")
          nsids, local = node.split(":")
          nsids = nsids.split("|")
          nsids.map { |nsid| "#{nsid}:#{local}" }
        else
          [node]
        end
      }
    end

  end
end
