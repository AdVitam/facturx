# frozen_string_literal: true

require_relative 'defaults'
require_relative 'version_probe'

module Facturx
  module Composers
    class Ghostscript
      class Locator
        Config = Data.define(:binary, :zugferd_ps, :icc_profile)
        ENV_KEYS = Defaults::ENV_KEYS

        def initialize(
          binary: nil,
          zugferd_ps: nil,
          icc_profile: nil,
          version_probe: VersionProbe.new,
          **discovery
        )
          @overrides = { binary:, zugferd_ps:, icc_profile: }
          @env = discovery.fetch(:env, ENV)
          candidates = discovery.fetch(:candidates, {})
          @zugferd_candidates = candidates.fetch(:zugferd_ps, Defaults::ZUGFERD_CANDIDATES)
          @icc_candidates = candidates.fetch(:icc_profile, Defaults::ICC_CANDIDATES)
          @version_probe = version_probe
        end

        def available?
          preflight!
          true
        rescue ComposerUnavailableError
          false
        end

        def preflight!
          candidate = config
          missing_resources = missing(candidate)
          raise_missing(missing_resources) unless missing_resources.empty?
          verify_version!(candidate.binary)
          @config = candidate
        end

        private

        def config
          @config || Config.new(
            binary: resolve_binary,
            zugferd_ps: resolve_resource(:zugferd_ps, @zugferd_candidates),
            icc_profile: resolve_resource(:icc_profile, @icc_candidates)
          )
        end

        def missing(candidate)
          candidate.to_h.filter_map { |name, value| name if value.nil? }
        end

        def raise_missing(resources)
          raise ComposerUnavailableError.new(
            "Ghostscript composition is unavailable: missing #{resources.join(', ')}",
            missing: resources
          )
        end

        def verify_version!(binary)
          @verify_version ||= @version_probe.call(binary)
        end

        def resolve_binary
          configured = configured_value(:binary)
          return find_executable(configured) if configured

          Defaults::BINARY_NAMES.lazy.filter_map { |name| find_executable(name) }.first
        end

        def resolve_resource(name, candidates)
          configured = configured_value(name)
          return readable_file(configured) if configured

          candidates.lazy.flat_map { |pattern| Dir.glob(pattern).reverse }.filter_map do |path|
            readable_file(path)
          end.first
        end

        def configured_value(name)
          override = @overrides.fetch(name)
          return override unless blank?(override)

          value = @env[ENV_KEYS.fetch(name)]
          value unless blank?(value)
        end

        def find_executable(value)
          path = value.to_s
          return executable_file(path) if path.include?(File::SEPARATOR) ||
                                          (File::ALT_SEPARATOR && path.include?(File::ALT_SEPARATOR))

          executable_extensions(path).each do |executable_name|
            search_paths.each do |directory|
              executable = executable_file(File.join(directory, executable_name))
              return executable if executable
            end
          end

          nil
        end

        def executable_extensions(name)
          return [name] unless Gem.win_platform? && File.extname(name) == ''

          extensions = @env.fetch('PATHEXT', '.COM;.EXE;.BAT;.CMD').split(';')
          [name, *extensions.map { |extension| "#{name}#{extension.downcase}" }]
        end

        def search_paths
          @env.fetch('PATH', '').split(File::PATH_SEPARATOR).reject(&:empty?)
        end

        def executable_file(path)
          expanded = File.expand_path(path)
          expanded if File.file?(expanded) && File.executable?(expanded)
        end

        def readable_file(path)
          expanded = File.expand_path(path.to_s)
          expanded if File.file?(expanded) && File.readable?(expanded)
        end

        def blank?(value)
          value.nil? || value.to_s.empty?
        end
      end
    end
  end
end
