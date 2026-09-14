# frozen_string_literal: true

require_relative '../../spec_helper'
require 'facturx/schematron/svrl_parser'

RSpec.describe Facturx::Schematron::SvrlParser do
  subject(:parser) { described_class.new }

  it 'maps failed assertions and successful reports in document order' do
    expect(parser.call(svrl: mixed_results)).to match(expected_issues)
  end

  it 'preserves missing optional SVRL attributes as nil' do
    issue = parser.call(svrl: svrl('<svrl:failed-assert><svrl:text>Invalid</svrl:text></svrl:failed-assert>')).first

    expect(issue).to have_attributes(path: nil, details: { rule_id: nil, test: nil, flag: nil })
  end

  it 'rejects unknown rule flags as a rule-pack failure' do
    xml = svrl('<svrl:failed-assert id="BR-1" flag="info"><svrl:text>Invalid</svrl:text></svrl:failed-assert>')
    error = rule_pack_error { parser.call(svrl: xml) }

    expect(error.details[:reason]).to eq(:unknown_flag)
  end

  it 'rejects results without a message' do
    xml = svrl('<svrl:failed-assert id="BR-1"/>')
    error = invalid_output_error { parser.call(svrl: xml) }

    expect(error.details).to include(reason: :missing_message, rule_id: 'BR-1')
  end

  it 'rejects malformed XML' do
    error = invalid_output_error { parser.call(svrl: '<svrl:schematron-output>') }

    expect(error.details[:reason]).to eq(:invalid_svrl)
  end

  it 'rejects XML with a document type' do
    error = invalid_output_error { parser.call(svrl: svrl_with_document_type) }

    expect(error.details[:reason]).to eq(:unexpected_svrl)
  end

  it 'rejects non-SVRL documents' do
    error = invalid_output_error { parser.call(svrl: '<schematron-output/>') }

    expect(error.details[:reason]).to eq(:unexpected_svrl)
  end

  def mixed_results
    svrl(<<~XML)
      <svrl:failed-assert id="BR-1" test="ram:ID" location="/invoice/header">
        <svrl:text>  Required   identifier  </svrl:text>
      </svrl:failed-assert>
      <svrl:successful-report id="BR-2" test="ram:Tax" location="/invoice/tax" flag="warning">
        <svrl:text>Review tax</svrl:text>
      </svrl:successful-report>
    XML
  end

  def expected_issues
    [
      have_attributes(
        code: :schematron_violation, message: 'Required identifier', layer: :schematron, severity: :error,
        path: '/invoice/header', details: { rule_id: 'BR-1', test: 'ram:ID', flag: nil }
      ),
      have_attributes(
        code: :schematron_violation, message: 'Review tax', layer: :schematron, severity: :warning,
        path: '/invoice/tax', details: { rule_id: 'BR-2', test: 'ram:Tax', flag: 'warning' }
      )
    ]
  end

  def svrl_with_document_type
    <<~XML
      <!DOCTYPE svrl:schematron-output>
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"/>
    XML
  end

  def invalid_output_error
    yield
  rescue Facturx::Schematron::InvalidOutputError => e
    e
  end

  def rule_pack_error
    yield
  rescue Facturx::Schematron::RulePackError => e
    e
  end

  def svrl(contents)
    <<~XML
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
        #{contents}
      </svrl:schematron-output>
    XML
  end
end
