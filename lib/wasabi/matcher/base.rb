module Wasabi
  module Matcher
    class Base

      def initialize(matcher)
        @matcher = parse(matcher)
      end

      private

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
end
