# frozen_string_literal: true

class InvoiceRecord < ActiveRecord::Base
  has_one_attached :invoice
end
