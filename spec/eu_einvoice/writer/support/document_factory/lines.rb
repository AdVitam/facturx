# frozen_string_literal: true

class WriterDocumentFactory
  class << self
    private

    def line
      EuEinvoice::Line.new(
        id: '1', note: 'Line note', product: product, quantity: quantity(2),
        gross_price: EuEinvoice::Price.new(amount: decimal('120'), basis_quantity: quantity(1),
                                           discount: decimal('20')),
        net_price: EuEinvoice::Price.new(amount: decimal('100'), basis_quantity: quantity(1)), tax: line_tax,
        period: period, net_amount: decimal('200'), allowances: [adjustment(false, tax: false)],
        charges: [adjustment(true, tax: false)], buyer_order_reference: EuEinvoice::DocumentReference.new(line_id: '10'),
        buyer_accounting_reference: 'LINE-ACCOUNT', invoiced_object_identifier: identifier('LINE-OBJECT', 'OBJ')
      )
    end

    def product
      EuEinvoice::Product.new(
        name: 'Product', description: 'Product description', seller_identifier: identifier('SELLER-PRODUCT'),
        buyer_identifier: identifier('BUYER-PRODUCT'), global_identifier: identifier('GLOBAL-PRODUCT', '0160'),
        origin_country_code: 'FR', attributes: product_attributes, classifications: product_classifications
      )
    end

    def product_attributes
      [EuEinvoice::ProductAttribute.new(name: 'Color', value: 'Blue')]
    end

    def product_classifications
      [EuEinvoice::ProductClassification.new(code: '1234', list_id: 'STI', list_version_id: '1')]
    end

    def quantity(value)
      EuEinvoice::Quantity.new(value: decimal(value.to_s), unit_code: 'C62')
    end

    def line_tax
      EuEinvoice::TaxBreakdown.new(type_code: 'VAT', category_code: 'S', rate: decimal('20'))
    end
  end
end
