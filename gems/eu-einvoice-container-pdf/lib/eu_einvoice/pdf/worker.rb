# frozen_string_literal: true

require 'json'
require 'base64'
require 'eu_einvoice/pdf/extractor'
require 'eu_einvoice/pdf/inspector'

module EuEinvoice
  module Pdf
    module Worker
      def self.call(operation, configuration, embedding)
        limits = ResourceLimits.new(**JSON.parse(configuration, symbolize_names: true))
        handler = { 'inspect' => Inspector, 'extract' => Extractor }.fetch(operation)
        result = handler.new(**options(operation, limits, embedding)).call($stdin).to_h
        %i[xml metadata].each { |key| result[key] = Base64.strict_encode64(result[key]) if result[key] }
        { result: }
      rescue EuEinvoice::Error => e
        { error: e.class.name, details: e.details }
      end

      def self.options(operation, limits, embedding)
        options = { limits:, isolate: false }
        options[:embedding] = Embedding.new(**JSON.parse(embedding, symbolize_names: true)) if operation == 'extract'
        options
      end

      private_class_method :options
    end
  end
end

$stdin.binmode
$stdout.write(JSON.generate(EuEinvoice::Pdf::Worker.call(*ARGV)))
