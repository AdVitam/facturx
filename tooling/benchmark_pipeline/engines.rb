# frozen_string_literal: true

module PipelineBenchmark
  module Engines
    module_function

    def versions
      runner = EuEinvoice::Subprocess::Runner.new
      saxon = EuEinvoice::Schematron::Locator.new(runner:).preflight!
      ghostscript = EuEinvoice::Composers::Ghostscript::Locator.new.preflight!
      { saxonc: { version: EuEinvoice::Schematron::VersionProbe.new(runner:).call(saxon).to_s,
                  executable_sha256: Digest::SHA256.file(saxon).hexdigest },
        ghostscript: ghostscript_metadata(ghostscript) }
    end

    def ghostscript_metadata(config)
      { version: EuEinvoice::Composers::Ghostscript::VersionProbe.new.call(config.binary).to_s,
        executable_sha256: Digest::SHA256.file(config.binary).hexdigest,
        zugferd_ps_sha256: Digest::SHA256.file(config.zugferd_ps).hexdigest,
        icc_profile_sha256: Digest::SHA256.file(config.icc_profile).hexdigest }
    end
  end
end
