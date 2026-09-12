# frozen_string_literal: true

require 'ripper'
require 'facturx/builders'

module Facturx
  module Rbi; end
end

RSpec.describe Facturx::Rbi do
  subject(:source) { File.read(path) }

  let(:path) { File.expand_path('../../rbi/facturx.rbi', __dir__) }

  it 'is valid Ruby syntax' do
    expect(Ripper.sexp(source)).not_to be_nil
  end

  it 'declares every generated builder and association helper' do
    expect(missing_builder_declarations).to be_empty
  end

  it 'declares document writing and conformance results' do
    expect(missing_writer_declarations).to be_empty
  end

  def missing_builder_declarations
    Facturx::Builders::Schema::ASSOCIATIONS.flat_map do |model, associations|
      builder = "class #{model.name.delete_prefix('Facturx::')}Builder < Base"
      helpers = associations.map { |attribute, item| "def #{item.collection ? item.helper : attribute}(" }
      [builder, *helpers].reject { |declaration| source.include?(declaration) }
    end
  end

  def missing_writer_declarations
    ['def validate_document(document:, profile:); end', 'def build_xml(document, profile:); end',
     'def generate(pdf:, document:, profile:); end', 'class ConformanceError < Error; end',
     'class Issue', 'class Report'].reject { |declaration| source.include?(declaration) }
  end
end
