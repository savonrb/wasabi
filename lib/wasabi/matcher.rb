module Wasabi
  class Matcher

    def initialize(matcher)
      matcher  = matcher.split(" > ")
      @matcher = matcher.map { |node| parse_matcher_node(node) }.reverse
    end

    def ===(stack)
      index = -1

      @matcher.each do |namespaces, local|
        node = stack[index]
        return false unless local == node.local && namespaces.include?(node.namespace)
        index -= 1
      end

      true
    end

    private

    def parse_matcher_node(node)
      nsids, local = node.split(":")
      namespaces = expand_namespace_ids nsids.split("|")
      [namespaces, local]
    end

    def expand_namespace_ids(nsids)
      nsids.map { |nsid|
        unless namespace = Wasabi::NAMESPACES[nsid]
          raise ArgumentError,
                "Invalid namespace identifier: #{nsid.inspect}\n" +
                "Valid namespace identifiers are: #{Wasabi::NAMESPACES.keys.inspect}"
        end
        namespace
      }
    end

  end
end
