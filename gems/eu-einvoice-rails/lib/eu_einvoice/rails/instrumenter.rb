# frozen_string_literal: true

require 'active_support/notifications'

module EuEinvoice
  module Rails
    class Instrumenter
      include EuEinvoice::Instrumenter

      def call(event, payload)
        failure = nil
        result = ActiveSupport::Notifications.instrument("#{event}.eu_einvoice", payload.dup) do |metadata|
          yield
        rescue StandardError => e
          metadata[:error_class] = e.class.name
          failure = e
        end
        raise failure if failure

        result
      end
    end
  end
end
