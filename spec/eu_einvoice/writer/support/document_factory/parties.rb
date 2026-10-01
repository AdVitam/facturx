# frozen_string_literal: true

class WriterDocumentFactory
  class << self
    private

    def party_attributes
      {
        seller: seller, buyer: buyer, payee: payee, tax_representative: tax_representative
      }
    end

    def address
      EuEinvoice::Address.new(
        postcode: '75001', line_one: '1 Main Street', line_two: 'Building A', line_three: 'Floor 2',
        city: 'Paris', country_code: 'FR', country_subdivision: 'IDF'
      )
    end

    def contact
      EuEinvoice::Contact.new(name: 'Contact', telephone: '+33123456789', email: 'contact@example.test')
    end

    def seller
      EuEinvoice::Party.new(
        identifiers: [identifier('SELLER-LOCAL'), identifier('SELLER-GLOBAL', '0088')], name: 'Seller',
        description: 'Seller description', legal_registration: identifier('SELLER-LEGAL', '0002'),
        trading_name: 'Seller Trading', address: address, vat_identifier: identifier('FR123', 'VA'),
        tax_identifier: identifier('TAX123', 'FC'), electronic_address: identifier('seller@example.test', 'EM'),
        contact: contact
      )
    end

    def buyer
      EuEinvoice::Party.new(
        identifiers: [identifier('BUYER-GLOBAL', '0088')], name: 'Buyer',
        legal_registration: identifier('BUYER-LEGAL', '0002'), trading_name: 'Buyer Trading', address: address,
        vat_identifier: identifier('FR456', 'VA'), electronic_address: identifier('buyer@example.test', 'EM'),
        contact: contact
      )
    end

    def payee
      EuEinvoice::Party.new(
        identifiers: [identifier('PAYEE-GLOBAL', '0088')], name: 'Payee',
        legal_registration: identifier('PAYEE-LEGAL', '0002')
      )
    end

    def tax_representative
      EuEinvoice::Party.new(name: 'Tax representative', address: address,
                            vat_identifier: identifier('FR789', 'VA'))
    end
  end
end
