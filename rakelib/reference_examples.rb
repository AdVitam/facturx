# frozen_string_literal: true

module Facturx
  module ReferenceExamples
    KNOWN_PAIR_MISMATCHES = {
      '3. EN16931/E04_Betriebskostenabrechnung_NEU/E04_01_Betriebskostenabrechnung_NEU.xml' => %w[
        15d37a7fb0901316c1dbd5037e64f9a531fb994a536f0404db41fc733d2f2b47
        14b08cb538ea0556b8e6256dea832a326140307c4ad1d9457428e51267885730
      ],
      '3. EN16931/E14_Kraftfahrversicherung/E14_01_Kraftfahrversicherung.xml' => %w[
        d4e8931a28232305d8973263708717ce2f252d23aef89ddf0d2a63220791644f
        62e9834a192a1cb0f4dcf7be8cc179a942ff4c5066441da58a26755caa579c27
      ]
    }.transform_values(&:freeze).freeze
    PROFILES = {
      '0. MINIMUM' => :minimum,
      '1. BASIC WL' => :basic_wl,
      '2. BASIC' => :basic,
      '3. EN16931' => :en16931,
      '4. EXTENDED' => :extended
    }.freeze
  end
end
