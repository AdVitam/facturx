# frozen_string_literal: true

module Facturx
  class Writer
    module Stages
      class TradeLines < Stage
        term_ids(*%w[
                   BT-126 BT-127 BT-157 BT-157-1 BT-155 BT-156 BT-153 BT-154 BT-160 BT-161 BT-158 BT-158-1
                   BT-158-2 BT-159 BT-132 BT-148 BT-149-1 BT-150-1 BT-147-01 BT-147-02 BT-147 BT-146 BT-149
                   BT-150 BT-129 BT-130 BT-151 BT-152 BT-134 BT-135 BT-138 BT-137 BT-136 BT-140 BT-139 BT-143
                   BT-142 BT-141 BT-145 BT-144 BT-131 BT-128 BT-128-1 BT-133
                 ])

        def initialize(context)
          super
          quantity = Quantity.new(context)
          @product = Product.new(context)
          @agreement = Agreement.new(context, quantity:)
          @settlement = Settlement.new(context)
          @quantity = quantity
        end

        def call
          each_group('BG-25', document.lines, element: 'ram:IncludedSupplyChainTradeLineItem',
                                              parent: context.transaction,
                                              represented_attributes: %i[
                                                gross_price net_price buyer_order_reference
                                              ]) do |node, line|
            line_document(node, line)
            @product.call(parent: node, value: line.product)
            @agreement.call(parent: node, line:)
            delivery(node, line)
            @settlement.call(parent: node, line:)
          end
        end

        private

        def line_document(parent, line)
          container(parent, 'ram:AssociatedDocumentLineDocument') do |node|
            emit('BT-126', line.id, element: 'ram:LineID', parent: node)
            if line.note
              container(node, 'ram:IncludedNote') do |note|
                emit('BT-127', line.note, element: 'ram:Content', parent: note)
              end
            else
              observe?('BT-127', nil)
            end
          end
        end

        def delivery(parent, line)
          node = context.element(parent, 'ram:SpecifiedLineTradeDelivery')
          @quantity.call(parent: node, value: line.quantity, amount_id: 'BT-129', unit_id: 'BT-130',
                         element: 'ram:BilledQuantity')
        end
      end
    end
  end
end

require_relative 'trade_lines/quantity'
require_relative 'trade_lines/product'
require_relative 'trade_lines/agreement'
require_relative 'trade_lines/settlement'
