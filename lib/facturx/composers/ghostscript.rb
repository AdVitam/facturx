# frozen_string_literal: true

require 'tmpdir'
require_relative '../embedding'
require_relative 'ghostscript/locator'
require_relative 'ghostscript/runner'

module Facturx
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

      def initialize(locator: Locator.new, runner: Runner.new)
        @locator = locator
        @runner = runner
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
          xml: File.join(directory, FACTURX_EMBEDDING.filename),
          output: File.join(directory, OUTPUT_FILENAME)
        )
      end

      def write_inputs(paths, pdf, xml)
        File.binwrite(paths.input, pdf)
        File.binwrite(paths.xml, xml)
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

        File.binread(path)
      end
    end
  end
end
