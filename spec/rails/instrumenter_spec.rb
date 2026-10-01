# frozen_string_literal: true

require 'eu_einvoice/rails'

RSpec.describe EuEinvoice::Rails::Instrumenter do
  it 'returns the operation result and publishes one event without mutating the payload' do
    payload = { byte_size: 3 }.freeze
    events = []
    subscriber = ->(*arguments) { events << ActiveSupport::Notifications::Event.new(*arguments) }

    ActiveSupport::Notifications.subscribed(subscriber, 'generate.eu_einvoice') do
      expect(described_class.new.call('generate', payload) { :artifact }).to eq(:artifact)
    end

    expect(events.map(&:payload)).to eq([{ byte_size: 3 }])
    expect(payload).to eq(byte_size: 3)
  end

  it 'propagates operation failures' do
    expect { described_class.new.call('generate', {}) { raise EuEinvoice::Error } }
      .to raise_error(EuEinvoice::Error)
  end

  it 'does not publish exception objects or their potentially sensitive messages' do
    events = []
    subscriber = ->(*arguments) { events << ActiveSupport::Notifications::Event.new(*arguments) }

    ActiveSupport::Notifications.subscribed(subscriber, 'generate.eu_einvoice') do
      expect { described_class.new.call('generate', {}) { raise EuEinvoice::Error, 'Customer data' } }
        .to raise_error(EuEinvoice::Error)
    end

    expect(events.map(&:payload)).to eq([{ error_class: 'EuEinvoice::Error' }])
  end
end
