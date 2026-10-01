# frozen_string_literal: true

require 'digest'

module EuEinvoice
  module France
    module Licensing
      CHECKSUMS = {
        'eu-einvoice-fr' => {
          'LICENSE.txt' =>
            '9cade36291c4461e10069722185bb02939790d6ce02d7707351833691790654f',
          'lib/eu_einvoice/schema/LICENSE-APACHE-2.0.txt' =>
            'c71d239df91726fc519c6eb72d318ec65820627232b2f796219e87dcf35d0ab4',
          'lib/eu_einvoice/schema/NOTICE.md' =>
            '705cb4a4a01feed2329328cf8b34002baeba50c5391267ee9681eea3e855bb66'
        }.freeze,
        'eu-einvoice-validation-fr' => {
          'LICENSE.txt' =>
            '9cade36291c4461e10069722185bb02939790d6ce02d7707351833691790654f',
          'NOTICE.md' =>
            '83eff3ea6564916456f40eeeafcb7c330d99a355d5d38fa35afcaeb3a7d151a5',
          'lib/eu_einvoice/schematron/rules/LICENSE-APACHE-2.0.txt' =>
            'c71d239df91726fc519c6eb72d318ec65820627232b2f796219e87dcf35d0ab4'
        }.freeze
      }.freeze

      class << self
        def verify!(package:, root:)
          CHECKSUMS.fetch(package).each do |path, expected|
            next if Digest::SHA256.file(File.join(root, path)).hexdigest == expected

            raise SchemaLoadError.new('License or notice checksum mismatch', reason: :checksum_mismatch, resource: path)
          end
        end

        def resources(package:)
          CHECKSUMS.fetch(package).transform_keys { |path| "license/#{package}/#{path}" }.freeze
        end
      end
    end
  end
end
