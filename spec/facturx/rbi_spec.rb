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
    ['def validate_document(document:, profile:); end', 'def build_xml(document:, profile:); end',
     'def generate(pdf:, document:, profile:); end', 'class ConformanceError < Error; end',
     'class Issue', 'class Report'].reject { |declaration| source.include?(declaration) }
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
