# frozen_string_literal: true

module EuEinvoice
  ProductAttribute = Model.define(:name, :value)
  ProductClassification = Model.define(:code, :list_id, :list_version_id)
  Product = Model.define(:name, :description, :seller_identifier, :buyer_identifier, :global_identifier,
                         :origin_country_code, :attributes, :classifications,
                         collections: %i[attributes classifications])
  Price = Model.define(:amount, :basis_quantity, :discount)
  Line = Model.define(:id, :note, :product, :quantity, :gross_price, :net_price, :tax, :period, :net_amount,
                      :allowances, :charges, :buyer_order_reference, :buyer_accounting_reference,
                      :invoiced_object_identifier,
                      collections: %i[allowances charges])
end
