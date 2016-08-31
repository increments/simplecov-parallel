module SimpleCov
  module Parallel
    module Adapter
      # @api private
      class Base
        def self.inherited(subclass)
          all_adapters << subclass
        end

        def self.all_adapters
          @all_adapters ||= []
        end

        def self.available?
          raise NotImplementedError
        end

        def activate
          raise NotImplementedError
        end
      end
    end
  end
end
