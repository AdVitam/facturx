# frozen_string_literal: true

module EuEinvoice
  module Rails
    class Configuration
      def initialize
        @clients = {}
      end

      def register(name, **)
        raise FrozenError, 'Invoice clients are sealed after application initialization' if frozen?

        key = name.to_sym
        raise Error.new('Client name already registered', name: key) if @clients.key?(key)

        @clients[key] = Client.new(instrumenter: Instrumenter.new, **)
      end

      def [](name)
        @clients.fetch(name.to_sym)
      end

      def seal!
        @clients.freeze
        freeze
      end
    end
  end
end
