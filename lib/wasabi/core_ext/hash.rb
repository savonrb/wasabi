module Wasabi
  module CoreExt
    module Hash

      def deep_merge(other_hash)
        self.merge(other_hash) do |key, oldval, newval|
          oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
          newval = newval.to_hash if newval.respond_to?(:to_hash)
          oldval.class.to_s == 'Hash' && newval.class.to_s == 'Hash' ? oldval.deep_merge(newval) : newval
        end
      end unless method_defined?(:deep_merge)

    end
  end
end

Hash.send :include, Wasabi::CoreExt::Hash
