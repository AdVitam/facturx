# frozen_string_literal: true

require 'open3'
require 'rbconfig'

RSpec.describe Facturx do
  it 'loads XML errors without the public facade' do
    expect(ruby_eval(xml_require_source)).to eq('Facturx::InvalidXmlError')
  end

  it 'loads composer errors without the public facade' do
    expect(ruby_eval(composer_require_source)).to eq('Facturx::ComposerUnavailableError')
  end

  it 'loads the attach orchestrator without the public facade' do
    expect(ruby_eval(attach_require_source)).to eq('Facturx::Attach')
  end

  it 'loads the reader without the public facade' do
    expect(ruby_eval(reader_require_source)).to eq('Facturx::Reader')
  end

  def ruby_eval(source)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-I#{File.expand_path('../lib', __dir__)}",
                                            '-e', source)
    raise stderr unless status.success?

    stdout
  end

  def xml_require_source
    <<~RUBY
      require 'facturx/xml/parser'
      begin
        Facturx::Xml::Parser.new.call(xml: nil)
      rescue Facturx::InvalidXmlError => error
        print error.class
      end
    RUBY
  end

  def composer_require_source
    <<~RUBY
      require 'facturx/composers/ghostscript'
      locator = Facturx::Composers::Ghostscript::Locator.new(
        binary: '/missing/gs', zugferd_ps: '/missing/zugferd.ps',
        icc_profile: '/missing/default_rgb.icc', env: { 'PATH' => '' },
        candidates: { zugferd_ps: [], icc_profile: [] }
      )
      begin
        locator.preflight!
      rescue Facturx::ComposerUnavailableError => error
        print error.class
      end
    RUBY
  end

  def attach_require_source
    "require 'facturx/attach'; print Facturx::Attach.new.class"
  end

  def reader_require_source
    "require 'facturx/reader'; print Facturx::Reader.new.class"
  end
end
