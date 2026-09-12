# frozen_string_literal: true

module Facturx
  DocumentReference = Model.define(:id, :scheme_id, :line_id, :type_code, :name, :issue_date)
  Delivery = Model.define(:location_identifier, :party, :date, :period)
  SupportingDocument = Model.define(:reference, :description, :external_location, :content, :mime_code, :filename)
end
