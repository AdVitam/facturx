# frozen_string_literal: true

require 'bundler/setup'
require 'eu_einvoice/fr'
require_relative '../pdf/support/pdf_builder'

abort "Usage: #{$PROGRAM_NAME} OUTPUT.pdf [PROFILE]" unless (1..2).cover?(ARGV.length)

profile = ARGV.fetch(1, 'en16931')
abort 'Unsupported profile' unless %w[minimum basic_wl basic en16931 extended].include?(profile)
xml = File.binread(File.expand_path("../fixtures/xml/#{profile}.xml", __dir__))
pdf = Object.new.extend(PdfSupport).build_pdf

client = EuEinvoice::Client.new(packs: [EuEinvoice::France::Pack.new], validation: :structural)
File.binwrite(ARGV.fetch(0), client.attach(pdf:, xml:).bytes)
