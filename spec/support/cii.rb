# frozen_string_literal: true

module CiiSupport
  def cii_profile_detector
    EuEinvoice::Xml::ProfileDetector.new(profiles: EuEinvoice::Profiles.all)
  end

  def cii_conformance
    schema_validator = EuEinvoice::Xml::SchemaValidator.new(registry: EuEinvoice::Xml::SchemaRegistry.new)
    EuEinvoice::Xml::ConformanceValidator.new(schema_validator:)
  end

  def cii_validator
    EuEinvoice::Xml::Validator.new(profile_detector: cii_profile_detector, conformance_validator: cii_conformance)
  end

  def cii_reader
    EuEinvoice::Reader.new(profile_resolver: cii_profile_detector)
  end
end
