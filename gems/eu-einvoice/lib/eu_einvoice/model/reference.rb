# frozen_string_literal: true

module EuEinvoice
  DocumentReference = Model.define(:id, :line_id, :name, :issue_date)
  Delivery = Model.define(:location_identifier, :party, :date)
  SupportingDocument = Model.define(:reference, :description, :external_location, :content, :mime_code, :filename)
end
