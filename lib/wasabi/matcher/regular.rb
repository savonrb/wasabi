require "wasabi/matcher/base"

module Wasabi
  module Matcher
    class Regular < Base

      def ===(stack)
        return false if @matcher.size != stack.size

        @matcher.each_with_index do |nodes, index|
          return false unless nodes.include?(stack[-(index+1)])
        end
        true
      end

    end
  end
end
