# frozen_string_literal: true

module Facturx
  TaxBreakdown = Model.define(:type_code, :category_code, :rate, :basis_amount, :tax_amount,
                              :exemption_reason, :exemption_reason_code, :due_date_type_code)
  AllowanceCharge = Model.define(:indicator, :amount, :base_amount, :percentage, :reason, :reason_code, :tax)
  Totals = Model.define(:line_total, :charge_total, :allowance_total, :tax_basis_total, :tax_total,
                        :tax_total_in_tax_currency, :grand_total, :prepaid, :rounding, :due_payable)
end
