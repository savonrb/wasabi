module Wasabi
  class Matcher

    def initialize(matcher)
      @matcher = parse(matcher)
    end

    def ===(stack)
      return false if @matcher.size != stack.size

      @matcher.each_with_index do |nodes, index|
        return false unless nodes.include?(stack[index])
      end
      true
    end

    private

    def parse(matcher)
      nodes = matcher.split(" > ")
      nodes.each_with_index do |node, index|
        nsids, local = node.split(":")
        nsids = nsids.split("|")
        nodes[index] = nsids.map { |nsid| "#{nsid}:#{local}" }
      end
      nodes
    end

  end
end
