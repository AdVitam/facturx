# frozen_string_literal: true

module Facturx
  Contact = Model.define(:name, :telephone, :email)
  Address = Model.define(:postcode, :line_one, :line_two, :line_three, :city, :country_code,
                         :country_subdivision)
  Party = Model.define(:identifiers, :name, :description, :legal_registration, :trading_name, :address,
                       :vat_identifier, :tax_identifier, :electronic_address, :contact,
                       collections: [:identifiers])
end
