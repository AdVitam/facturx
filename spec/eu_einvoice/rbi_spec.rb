# frozen_string_literal: true

require 'ripper'

module EuEinvoice
  module Rbi; end
end

RSpec.describe EuEinvoice::Rbi do
  subject(:source) { paths.map { |path| File.read(path) }.join("\n") }

  let(:root) { File.expand_path('../..', __dir__) }
  let(:paths) { Dir[File.join(root, 'gems/*/rbi/*.rbi')].sort }
  let(:immutable_methods) { %w[initialize with] }
  let(:immutable_types) do
    %w[
      Address AllowanceCharge Contact CreditTransfer Delivery Diagnostic DirectDebit Document DocumentReference
      Identifier Line Note Party PaymentCard PaymentInstructions Period Price Product ProductAttribute
      ProductClassification Profile Quantity Reading Specification SupportingDocument TaxBreakdown Totals
    ]
  end
  let(:public_api_declarations) do
    [
      'class Client',
      'def validate_xml(xml:, specification: nil); end',
      'def validate_document(document:, specification: nil, resolution: nil, allow_loss: false); end',
      'def build_xml(document:, specification: nil, resolution: nil, allow_loss: false); end',
      'def generate(document:, pdf:, specification: nil, resolution: nil, allow_loss: false); end',
      'class InvalidDocumentError < ValidationError; end',
      'module Validation',
      'class Issue',
      'class Report',
      'def complete?; end',
      'class Artifact',
      'class Policy',
      'class Resolution',
      'class ResourceLimits',
      'class FrenchAddress',
      'class Configuration'
    ]
  end

  it 'is valid Ruby syntax' do
    paths.each do |path|
      content = File.read(path)
      expect([content.start_with?("# typed: strict\n"), Ripper.sexp(content).nil?]).to eq([true, false])
    end
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

  it 'declares the unified client and extension public contracts' do
    expect(missing_public_api_declarations).to be_empty
  end

  it 'keeps country declarations out of core signatures' do
    core = Dir[File.join(root, 'gems/eu-einvoice/rbi/*.rbi')].map { |path| File.read(path) }.join

    expect(core).not_to include('module Profiles', 'module France', 'module Rails')
  end

  it 'uses concrete builder arguments and reserves untyped values for diagnostic details' do
    untyped = source.lines.each_cons(2).select do |line, following|
      line.include?('T.untyped') && !line.include?('details') && !following.match?(/(?:attr_reader :|def )details/)
    end

    expect(untyped).to be_empty
    expect(source).not_to include('T.unsafe')
  end

  it 'does not retain the removed static facade' do
    core = File.read(File.join(root, 'gems/eu-einvoice/rbi/eu-einvoice.rbi'))

    expect(core).not_to include('def generate(pdf:, document:, profile:)', 'def validate_xml(xml:)')
  end

  it 'declares constructors and immutable updates for every public data type' do
    expect(missing_immutable_methods).to be_empty
  end

  it 'does not declare internal services as public types' do
    internal_types = /(?:Attach|Coerce|Composers|Format|Generate|Model|Pdf|Reader|Writer|Xml)/

    expect(source).not_to match(/^  (?:class|module) #{internal_types}\b/)
  end

  def missing_builder_declarations
    EuEinvoice::Builders::Schema::ASSOCIATIONS.flat_map do |model, associations|
      builder = "class #{model.name.delete_prefix('EuEinvoice::')}Builder < Base"
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
