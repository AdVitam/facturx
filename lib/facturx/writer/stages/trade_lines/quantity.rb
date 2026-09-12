# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      class TradeLines
        class Quantity < Stage
          def call(parent:, value:, amount_id:, unit_id:, element:)
            node = emit(amount_id, value&.value, element:, parent:).first
            emit_attribute(unit_id, value&.unit_code, node:, attribute: 'unitCode',
                                                      group_present: !value&.value.nil?)
          end
        end
      end
    end
  end
end
