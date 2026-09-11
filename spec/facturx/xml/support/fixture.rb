# frozen_string_literal: true

module XmlFixtureSupport
  def xml_fixture(profile)
    File.binread(File.expand_path("../../../fixtures/xml/#{profile}.xml", __dir__))
  end
end
