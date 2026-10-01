# frozen_string_literal: true

require 'nokogiri'

document = Nokogiri::XML(File.read(ARGV.fetch(0))) { |config| config.strict.nonet }
reports = document.xpath('//*[local-name()="validationReport"]')
abort 'veraPDF did not confirm PDF/A compliance' if reports.empty? || reports.any? do |report|
  report['isCompliant'] != 'true'
end
