# frozen_string_literal: true

require 'bundler/setup'
require 'facturx'
require_relative '../pdf/support/pdf_builder'

abort "Usage: #{$PROGRAM_NAME} OUTPUT.pdf" unless ARGV.one?

xml = File.binread(File.expand_path('../fixtures/xml/en16931.xml', __dir__))
pdf = Object.new.extend(PdfSupport).build_pdf

File.binwrite(ARGV.fetch(0), Facturx.attach(pdf:, xml:))
