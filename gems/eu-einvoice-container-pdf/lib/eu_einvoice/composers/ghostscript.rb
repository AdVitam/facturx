# frozen_string_literal: true

require 'tmpdir'
require 'eu_einvoice/pdf/embedding'
require 'eu_einvoice/resource_limits'
require 'eu_einvoice/source'
require 'eu_einvoice/composers/ghostscript/locator'
require 'eu_einvoice/composers/ghostscript/runner'

module EuEinvoice
  module Composers
    class Ghostscript
      INPUT_FILENAME = 'input.pdf'
      OUTPUT_FILENAME = 'output.pdf'
      DEVICE_ARGUMENTS = %w[
        -dBATCH
        -dNOPAUSE
        -sDEVICE=pdfwrite
        -dPDFA=3
        -dPDFACompatibilityPolicy=1
        -sColorConversionStrategy=RGB
      ].freeze

      Paths = Data.define(:input, :xml, :output)

      def initialize(embedding:, limits: ResourceLimits.new, locator: Locator.new, runner: Runner.new(limits:))
        @locator = locator
        @runner = runner
        @limits = limits
        @embedding = embedding
      end

      def available?
        @locator.available?
      end

      def preflight!
        @locator.preflight!
      end

      def call(pdf:, xml:, profile:)
        config = preflight!
        Dir.mktmpdir('facturx-') do |directory|
          paths = paths_for(directory)
          write_inputs(paths, pdf, xml)
          @runner.call(arguments(config, paths, profile))
          read_output(paths.output)
        end
      rescue SystemCallError => e
        raise_temporary_file_error(e)
      end

      private

      def raise_temporary_file_error(error)
        raise CompositionError.new(
          "Ghostscript composition failed while handling temporary files: #{error.message}",
          cause: error.class.name
        )
      end

      def paths_for(directory)
        Paths.new(
          input: File.join(directory, INPUT_FILENAME),
          xml: File.join(directory, @embedding.filename),
          output: File.join(directory, OUTPUT_FILENAME)
        )
      end

      def write_inputs(paths, pdf, xml)
        File.binwrite(paths.input, Source.read(pdf, limit: @limits.pdf_bytes))
        File.binwrite(paths.xml, Source.read(xml, limit: @limits.xml_bytes))
      end

      def arguments(config, paths, profile)
        [config.binary, permitted_files_argument(config, paths)] + DEVICE_ARGUMENTS +
          zugferd_arguments(config, paths, profile) + ['-o', paths.output, config.zugferd_ps, paths.input]
      end

      def permitted_files_argument(config, paths)
        permitted_files = [
          paths.input,
          paths.xml,
          config.zugferd_ps,
          config.icc_profile
        ].join(File::PATH_SEPARATOR)

        "--permit-file-read=#{permitted_files}"
      end

      def zugferd_arguments(config, paths, profile)
        [
          "-sZUGFeRDXMLFile=#{paths.xml}",
          "-sZUGFeRDProfile=#{config.icc_profile}",
          '-sZUGFeRDVersion=2p1',
          "-sZUGFeRDConformanceLevel=#{profile.conformance_level}"
        ]
      end

      def read_output(path)
        unless File.file?(path) && File.size?(path)
          raise CompositionError, 'Ghostscript did not produce a non-empty PDF'
        end

        @limits.check!(:output_pdf_bytes, File.size(path))
        File.open(path, 'rb') { |file| Source.read(file, limit: @limits.output_pdf_bytes) }
      end
    end
  end
end
