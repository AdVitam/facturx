# frozen_string_literal: true

require 'active_model'
require 'i18n'

module EuEinvoice
  module Rails
    class ErrorAdapter
      class << self
        def apply(record, report:, attributes: {})
          report.issues.each do |issue|
            next unless issue.severity == :error

            attribute = attributes.fetch(issue.term_id, :base)
            record.errors.add(attribute, :eu_einvoice, message: message(issue),
                                                       code: issue.code, term_id: issue.term_id, path: issue.path)
          end
          record.errors
        end

        private

        def message(issue)
          I18n.t(issue.code.to_s, scope: %i[eu_einvoice errors],
                                  default: [:invalid, 'Invalid invoice data'])
        end
      end
    end
  end
end
