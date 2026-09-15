# frozen_string_literal: true

require 'spec_helper'
require_relative '../pdf/support/pdf_builder'

RSpec.describe 'README quickstart', :saxonc do
  include PdfSupport

  it 'runs the documented configuration and memory-only generation with full validation' do
    snippets = File.read(File.expand_path('../../README.md', __dir__)).scan(/```ruby\n(.*?)```/m).flatten
    configuration = snippets.find { |snippet| snippet.include?('client = EuEinvoice::Client.new') }
    generation = snippets.find { |snippet| snippet.include?('document = EuEinvoice::Document.build') }
    context = binding
    context.local_variable_set(:rendered_pdf_bytes, build_pdf)
    context.eval(configuration)
    context.eval(generation)
    artifact = context.local_variable_get(:pdf)
    expect(artifact.report).to be_complete
    expect(artifact.report).to be_valid
    expect(artifact.bytes).to start_with('%PDF-')
  end
end
