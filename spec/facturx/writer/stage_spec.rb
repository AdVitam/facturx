# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Facturx::Writer::Stage do
  let(:profile) { Facturx::Profiles.fetch(:minimum) }
  let(:tracker) { Facturx::Conformance::Tracker.new(profile:) }
  let(:context) { Facturx::Writer::Context.new(document: Facturx::Document.new, profile:, tracker:) }

  context 'with a forbidden term' do
    subject(:invoke) { stage.new(context).call }

    let(:stage) do
      Class.new(described_class) do
        def call
          emit('BT-22', 'forbidden', element: 'ram:Content', parent: context.root)
        end
      end
    end

    it 'does not emit the term' do
      invoke
      expect(context.root.element_children).to be_empty
    end

    it 'reports the forbidden term' do
      invoke
      expect(tracker.report.issues).to include(have_attributes(code: :forbidden_term, term_id: 'BT-22'))
    end
  end

  context 'with a forbidden group' do
    subject(:invoke) { stage.new(context).call }

    let(:events) { [] }
    let(:stage) do
      observed = events
      Class.new(described_class) do
        define_method(:call) do
          within_group('BG-1', Facturx::Note.new(content: 'forbidden'),
                       element: 'ram:IncludedNote', parent: context.root) { observed << :descended }
        end
      end
    end

    it 'does not descend into the group' do
      invoke
      expect(events).to be_empty
    end

    it 'does not emit the group' do
      invoke
      expect(context.root.element_children).to be_empty
    end

    it 'reports the forbidden group' do
      invoke
      expect(tracker.report.issues).to include(have_attributes(code: :forbidden_group, group_id: 'BG-1'))
    end
  end
end
