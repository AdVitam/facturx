# frozen_string_literal: true

require 'facturx'

%i[
  Attach Builders Coerce CoercionError Composers Format FormattingError Generate Group Model Pdf ProfileResolver
  Reader SourceReader Term TermDeclarations Terms Writer Xml
].each { |name| Facturx.public_constant(name) }
Facturx::Profiles.public_constant(:BY_ID, :BY_GUIDELINE_URN)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.order = :random
end
