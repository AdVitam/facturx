# frozen_string_literal: true

require 'spec_helper'
require 'open3'

RSpec.describe 'Core semantic loading' do
  it 'exposes the semantic SDK without loading a country, syntax, container or Rails' do
    output, status = Open3.capture2(Gem.ruby, '-I', File.expand_path('gems/eu-einvoice/lib'), '-e', core_script)
    expect([output.strip, status.success?]).to eq(['2017,date,184,0', true])
  end

  def core_script
    <<~RUBY
      require 'eu_einvoice'
      forbidden = $LOADED_FEATURES.grep(%r{eu_einvoice/(?:fr(?:/|\\.rb)|xml/|pdf/|syntax/)|nokogiri|active_record|active_model|rails/})
      fields = [EuEinvoice::Document.new.semantic_version, EuEinvoice::Semantic::En16931.fetch('BT-2').type,
                EuEinvoice::Semantic::En16931::TERMS.size, forbidden.size]
      puts fields.join(',')
    RUBY
  end
end
