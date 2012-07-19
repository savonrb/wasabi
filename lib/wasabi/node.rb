module Wasabi
  class Node

    def initialize(namespace, local, attrs = {})
      @namespace = namespace
      @local = local
      @attrs = attrs
    end

    attr_reader :namespace, :local, :attrs

    def [](key)
      @attrs[key]
    end

    def inspect
      "{#{namespace}}:#{local}"
    end

  end
end
