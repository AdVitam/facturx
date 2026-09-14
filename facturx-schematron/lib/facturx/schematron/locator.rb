# frozen_string_literal: true

require_relative 'error'
require_relative 'version_probe'

module Facturx
  module Schematron
    class Locator
      ENV_KEY = 'FACTURX_SAXONC_TRANSFORM'
      BINARY_NAME = 'Transform'
      private_constant :ENV_KEY, :BINARY_NAME

      def initialize(runner:, binary: nil, env: ENV)
        @binary = binary
        @env = env
        @version_probe = VersionProbe.new(runner:)
      end

      def preflight!
        @preflight ||= begin
          binary = resolve_binary
          raise_missing unless binary

          @version_probe.call(binary)
          binary
        end
      end

      private

      def resolve_binary
        configured = @binary || @env[ENV_KEY]
        return find_executable(configured) if configured && !configured.empty?

        find_executable(BINARY_NAME)
      end

      def find_executable(value)
        path = value.to_s
        return executable_file(path) if path.include?(File::SEPARATOR) || alt_separator?(path)

        executable_names(path).each do |name|
          search_paths.each do |directory|
            executable = executable_file(File.join(directory, name))
            return executable if executable
          end
        end
        nil
      end

      def executable_names(name)
        return [name] unless Gem.win_platform? && File.extname(name).empty?

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

      def alt_separator?(path)
        File::ALT_SEPARATOR && path.include?(File::ALT_SEPARATOR)
      end

      def raise_missing
        raise UnavailableError.new(
          'Schematron validation is unavailable: SaxonC Transform was not found',
          reason: :missing_binary,
          environment_variable: ENV_KEY
        )
      end
    end
  end
end
