# frozen_string_literal: true

pack = EuEinvoice::France::Pack.new
Rails.application.config.eu_einvoice.register(:initializer, packs: [pack], validation: :structural)
