# frozen_string_literal: true

module EuEinvoice
  module Composers
    class Ghostscript
      module Defaults
        ENV_KEYS = {
          binary: 'EU_EINVOICE_GHOSTSCRIPT',
          zugferd_ps: 'EU_EINVOICE_ZUGFERD_PS',
          icc_profile: 'EU_EINVOICE_RGB_ICC_PROFILE'
        }.freeze
        BINARY_NAMES = %w[gs gswin64c.exe gswin32c.exe].freeze
        ZUGFERD_CANDIDATES = [
          '/usr/share/ghostscript/*/lib/zugferd.ps',
          '/usr/local/share/ghostscript/*/lib/zugferd.ps',
          '/opt/homebrew/share/ghostscript/*/lib/zugferd.ps',
          '/opt/local/share/ghostscript/*/lib/zugferd.ps'
        ].freeze
        ICC_CANDIDATES = [
          '/usr/share/color/icc/ghostscript/default_rgb.icc',
          '/usr/share/ghostscript/*/iccprofiles/default_rgb.icc',
          '/usr/local/share/ghostscript/*/iccprofiles/default_rgb.icc',
          '/opt/homebrew/share/ghostscript/*/iccprofiles/default_rgb.icc',
          '/opt/local/share/ghostscript/*/iccprofiles/default_rgb.icc'
        ].freeze
      end
    end
  end
end
