# frozen_string_literal: true

require_relative '../error'
require_relative '../profiles'

module Facturx
  module Xml
    class SchemaRegistry
      SPECIFICATION_VERSION = '1.09.2'
      ROOT = File.expand_path("../schema/#{SPECIFICATION_VERSION}", __dir__).freeze
      PATHS = {
        minimum: 'minimum/Factur-X_1.09.2_MINIMUM.xsd',
        basic_wl: 'basic-wl/Factur-X_1.09.2_BASICWL.xsd',
        basic: 'basic/Factur-X_1.09.2_BASIC.xsd',
        en16931: 'en16931/Factur-X_1.09.2_EN16931.xsd',
        extended: 'extended/Factur-X_1.09.2_EXTENDED.xsd'
      }.transform_values { |path| File.join(ROOT, path).freeze }.freeze
      private_constant :SPECIFICATION_VERSION, :ROOT, :PATHS

      def fetch(profile)
        PATHS.fetch(profile.id)
      rescue KeyError
        raise SchemaLoadError.new('Factur-X schema is unavailable', profile: profile.id)
      end
    end
  end
end
