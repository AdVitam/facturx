# frozen_string_literal: true

require 'open3'

RSpec.describe 'Package boundaries' do
  def evaluate(source)
    stdout, stderr, status = Open3.capture3(Gem.ruby, '-rbundler/setup', '-e', source)
    raise stderr unless status.success?

    stdout
  end

  it 'loads the core without XML, PDF, Rails or French packs' do
    output = evaluate("require 'eu_einvoice'; puts [defined?(Nokogiri), defined?(PDF), defined?(Rails), defined?(EuEinvoice::France)].compact")
    expect(output).to be_empty
  end

  it 'constructs the semantic model without format extensions' do
    expect(evaluate("require 'eu_einvoice'; print EuEinvoice::Document.build(invoice_number: 'INV-1').invoice_number"))
      .to eq('INV-1')
  end

  it 'does not change existing clients when validation is required' do
    output = evaluate(<<~RUBY)
      require 'eu_einvoice/fr'
      client = EuEinvoice::Client.new(packs: [EuEinvoice::France::Pack.new], validation: :structural)
      require 'eu_einvoice/validation/fr'
      print client.validation
    RUBY
    expect(output).to eq('structural')
  end

  it 'exposes the syntax context contract to core-only extensions' do
    output = evaluate(<<~RUBY)
      require 'eu_einvoice'
      context = EuEinvoice::Validation::Context.new(source: '<invoice/>', representation: Object.new, syntax: :example)
      print context.syntax
    RUBY
    expect(output).to eq('example')
  end
end
