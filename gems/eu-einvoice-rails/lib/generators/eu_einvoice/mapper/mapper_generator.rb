# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/named_base'

module EuEinvoice
  module Generators
    class MapperGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def create_mapper
        template 'mapper.rb.tt', File.join('app/mappers', class_path, "#{file_name}_mapper.rb")
      end
    end
  end
end
