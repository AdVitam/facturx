# frozen_string_literal: true

module EuEinvoice
  Note = Model.define(:content, :subject_code)
  Identifier = Model.define(:value, :scheme_id)
  Period = Model.define(:start_date, :end_date)
  Quantity = Model.define(:value, :unit_code)
end
