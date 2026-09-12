# frozen_string_literal: true

require_relative 'reference_workbook'

module Facturx
  class ReferenceTermRegistry
    def initialize(root:)
      @root = root
    end

    def verify(references)
      references.each do |profile_id, (relative_path, _sha256)|
        official = ReferenceWorkbook.new(path: File.join(@root, relative_path)).cardinalities
        mismatches = mismatches(profile_id, official)
        next if mismatches.empty?

        raise "Term registry mismatch for #{profile_id}:\n#{mismatches.join("\n")}"
      end
    end

    private

    def mismatches(profile_id, official)
      Terms.all.filter_map do |term|
        expected = term.cardinalities[profile_id]
        actual = official[term.id]
        "#{term.id}: declared #{expected.inspect}, official #{actual.inspect}" unless expected == actual
      end
    end
  end
end
