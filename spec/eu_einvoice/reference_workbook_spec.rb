# frozen_string_literal: true

require 'tempfile'
require 'zip'
require_relative '../../rakelib/reference_workbook'

RSpec.describe EuEinvoice::ReferenceWorkbook do
  subject(:cardinalities) { described_class.new(path: workbook.path, term_ids: %w[BT-1 BT-2]).cardinalities }

  let(:workbook) { build_workbook }

  after { workbook.close! }

  it 'reads the EN16931 cardinality and ignores malformed untargeted pseudo-terms' do
    expect(cardinalities).to eq('BT-1' => '1..1', 'BT-2' => '0..1')
  end

  it 'rejects a malformed cardinality for a targeted term' do
    reader = described_class.new(path: workbook.path, term_ids: %w[BT-1 BT-2 BT-2-0])

    expect { reader.cardinalities }.to raise_error(RuntimeError, /Missing cardinality for BT-2-0/)
  end

  def build_workbook
    Tempfile.new(['reference', '.xlsx']).tap { |file| write_workbook(file) }
  end

  def write_workbook(file)
    Zip::OutputStream.open(file.path) do |archive|
      workbook_entries.each do |path, content|
        archive.put_next_entry(path)
        archive.write(content)
      end
    end
  end

  def workbook_entries
    {
      'xl/workbook.xml' => workbook_xml,
      'xl/_rels/workbook.xml.rels' => relationships_xml,
      'xl/sharedStrings.xml' => shared_strings,
      'xl/worksheets/sheet1.xml' => worksheet(irrelevant_rows),
      'xl/worksheets/sheet2.xml' => worksheet(semantic_rows)
    }
  end

  def workbook_xml
    <<~XML
      <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
        <sheets><sheet name="Notes" sheetId="1" r:id="rId1"/><sheet name="Model" sheetId="2" r:id="rId2"/></sheets>
      </workbook>
    XML
  end

  def relationships_xml
    <<~XML
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <Relationship Id="rId1" Target="worksheets/sheet1.xml"/>
        <Relationship Id="rId2" Target="worksheets/sheet2.xml"/>
      </Relationships>
    XML
  end

  def shared_strings
    <<~XML
      <sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
        <si><t>ID</t></si><si><t>EN16931 Cardinality</t></si><si><t>BT-1</t></si><si><t>1..1</t></si>
        <si><r><t>BT-</t></r><r><t>2</t></r></si><si><t>0..n</t></si>
      </sst>
    XML
  end

  def irrelevant_rows
    '<row r="1"><c r="A1" t="inlineStr"><is><t>BT-1 appears in prose</t></is></c></row>'
  end

  def semantic_rows
    <<~XML
      <row r="1"><c r="A1" t="s"><v>0</v></c><c r="B1" t="s"><v>1</v></c><c r="E1" t="inlineStr"><is><t>Card.</t></is></c></row>
      <row r="2"><c r="A2" t="s"><v>2</v></c><c r="B2" t="s"><v>3</v></c><c r="E2" t="s"><v>5</v></c></row>
      <row r="3"><c r="A3" t="s"><v>4</v></c><c r="B3" t="inlineStr"><is><t>0..1</t></is></c></row>
      <row r="4"><c r="A4" t="inlineStr"><is><t>BT-2-0</t></is></c><c r="B4" t="inlineStr"><is><t>0..1 0..1</t></is></c></row>
    XML
  end

  def worksheet(rows)
    <<~XML
      <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>#{rows}</sheetData></worksheet>
    XML
  end
end
