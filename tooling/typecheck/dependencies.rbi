# typed: strict

# Minimal external type surface for the isolated shipped-RBI smoke check.
module ActiveModel
  class Errors; end
  module Validations
    sig { returns(ActiveModel::Errors) }
    def errors; end
  end
end

module Nokogiri
  module XML
    class Document; end
  end
end
