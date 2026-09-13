# frozen_string_literal: true

require 'ripper'

module Facturx
  module Rbi; end
end

RSpec.describe Facturx::Rbi do
  subject(:source) { File.read(path) }

  let(:path) { File.expand_path('../../rbi/facturx.rbi', __dir__) }
  let(:immutable_methods) { %w[initialize with] }
  let(:immutable_types) do
    %w[
      Address AllowanceCharge Contact CreditTransfer Delivery Diagnostic DirectDebit Document DocumentReference
      Identifier Line Note Party PaymentCard PaymentInstructions Period Price Product ProductAttribute
      ProductClassification Profile Quantity Reading SupportingDocument TaxBreakdown Totals
    ]
  end
  let(:public_api_declarations) do
    [
      'def validate_xml(xml:); end',
      'def validate_document(document:, profile:); end',
      'def build_xml(document:, profile:); end',
      'def generate(pdf:, document:, profile:); end',
      'class InvalidDocumentError < ValidationError; end',
      'module Validation',
      'class Issue',
      'class Report',
      'def self.all; end',
      'def self.fetch(id); end',
      'def self.for_guideline_urn(guideline_urn); end'
    ]
  end

  it 'is valid Ruby syntax' do
    expect([source.start_with?("# typed: strict\n"), Ripper.sexp(source).nil?]).to eq([true, false])
  end

  it 'types every declared accessor' do
    expect(attribute_declarations.filter_map { |item| item[:signature] ? nil : item[:line] }).to be_empty
  end

  it 'uses each writer name as its Sorbet parameter' do
    expect(invalid_writer_declarations).to be_empty
  end

  it 'gives model and builder accessors concrete value types' do
    untyped = attribute_declarations.filter_map do |item|
      next if item[:names] == ['details']

      item[:line] if item[:signature]&.include?('T.untyped')
    end

    expect(untyped).to be_empty
  end

  it 'declares every generated builder and association helper' do
    expect(missing_builder_declarations).to be_empty
  end

  it 'declares document writing and conformance results' do
    expect(missing_public_api_declarations).to be_empty
  end

  it 'declares constructors and immutable updates for every public data type' do
    expect(missing_immutable_methods).to be_empty
  end

  it 'does not declare internal services as public types' do
    internal_types = /(?:Attach|Coerce|Composers|Format|Generate|Model|Pdf|Reader|Writer|Xml)/

    expect(source).not_to match(/^  (?:class|module) #{internal_types}\b/)
  end

  def missing_builder_declarations
    builders = Facturx.const_get(:Builders, false)
    schema = builders.const_get(:Schema, false)
    schema::ASSOCIATIONS.flat_map do |model, associations|
      builder = "class #{model.name.delete_prefix('Facturx::')}Builder < Base"
      helpers = associations.map { |attribute, item| "def #{item.collection ? item.helper : attribute}(" }
      [builder, *helpers].reject { |declaration| source.include?(declaration) }
    end
  end

  def missing_public_api_declarations
    public_api_declarations.reject { |declaration| source.include?(declaration) }
  end

  def missing_immutable_methods
    immutable_types.flat_map do |name|
      declaration = top_level_class_declaration(name)
      next ["class #{name}"] unless declaration

      immutable_methods
        .reject { |method| declaration.match?(/^    def #{method}\b/) }
        .map { |method| "#{name}##{method}" }
    end
  end

  def top_level_class_declaration(name)
    start = source.index(/^  class #{name}\b/)
    return unless start

    finish = source.index(/^  (?:class|module)\b/, start + 1) || source.length
    source[start...finish]
  end

  def attribute_declarations
    lines = source.lines
    lines.each_index.filter_map { |index| attribute_declaration(lines, index) }
  end

  def attribute_declaration(lines, index)
    match = lines[index].match(/^\s*attr_(reader|writer|accessor)\s+(.+)$/)
    return unless match

    declaration = continued_declaration(lines, index)
    { kind: match[1], names: declaration.scan(/:(\w+)/).flatten, signature: signature_before(lines, index),
      line: index + 1 }
  end

  def continued_declaration(lines, index)
    declaration = lines[index].dup
    declaration << lines[index += 1] while declaration.rstrip.end_with?(',')
    declaration
  end

  def signature_before(lines, index)
    cursor = previous_content_line(lines, index - 1)
    return lines[cursor].strip if lines[cursor]&.strip&.start_with?('sig {')
    return unless lines[cursor]&.strip == 'end'

    multiline_signature(lines, cursor)
  end

  def previous_content_line(lines, cursor)
    cursor -= 1 while cursor >= 0 && lines[cursor].strip.empty?
    cursor
  end

  def multiline_signature(lines, end_index)
    cursor = end_index - 1
    while cursor >= 0
      return lines[cursor..end_index].join if lines[cursor].strip == 'sig do'
      return if lines[cursor].match?(/^\s*(?:attr_|class |def |module |end\b)/)

      cursor -= 1
    end
  end

  def invalid_writer_declarations
    attribute_declarations.filter_map do |item|
      next unless item[:kind] == 'writer'

      signature = item[:signature]
      item[:line] unless signature && item[:names].one? && signature.match?(/params\(#{item[:names].first}:/)
    end
  end
end
