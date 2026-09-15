# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'
require 'eu_einvoice/rails'
require 'generators/eu_einvoice/mapper/mapper_generator'

RSpec.describe EuEinvoice::Generators::MapperGenerator do
  it 'generates an executable mapper with no persistence callbacks' do
    Dir.mktmpdir('eu-einvoice-generator-') do |directory|
      described_class.start(['invoice'], destination_root: directory, quiet: true)
      source = File.read(File.join(directory, 'app/mappers/invoice_mapper.rb'))
      namespace = Module.new
      namespace.module_eval(source)
      record = Struct.new(:id).new(123)

      expect(namespace.const_get(:InvoiceMapper).new.call(record).invoice_number).to eq('123')
    end
  end
end
