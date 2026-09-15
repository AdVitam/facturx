# frozen_string_literal: true

module EuEinvoice
  module Terms
    REFERENCE_VERSION = 'Factur-X 1.09.2 / ZUGFeRD 2.5.2'
    REFERENCE_FILES = {
      minimum: ['Schema/0_Factur-X_1.09.2_MINIMUM/Factur-X_1.09.2_MINIMUM.xlsx',
                '81c979b61ccfe9c4cdee2c8c346d094a41e0fe61656f6285f951f3e8bf94a32e'],
      basic_wl: ['Schema/1_Factur-X_1.09.2_BASICWL/Factur-X_1.09.2_BASICWL.xlsx',
                 '21521b45ad32dad015019b3c53eaf751e90d94b6e62853cf22d6b9e2413b9d94'],
      basic: ['Schema/2_Factur-X_1.09.2_BASIC/Factur-X_1.09.2_BASIC.xlsx',
              '662955f7666c58c526b9c1e58730fe2824596381696e0999e184d63662b02a32'],
      en16931: ['Schema/3_Factur-X_1.09.2_EN16931/Factur-X_1.09.2_EN16931.xlsx',
                '306514903279bd1d425fe3280286d1441b811bfc8e031dab671129ff4495d049'],
      extended: ['Schema/4_Factur-X_1.09.2_EXTENDED/Factur-X_1.09.2_EXTENDED.xlsx',
                 '80777478de352ab37e536b7e07e67ab5dc196cbbe700fe95326d61118f62cfd4'],
      en16931_appendix: ['Documentation/6_Factur-X_1.09.2_ZUGFeRD_2.5.2_Technical_Appendix_Profile_EN16931.pdf',
                         'b8c5a1a2f857418e3dacc1d3026aaa7b3cac7d385d7cfe1f37856fc994d55e53']
    }.transform_values { |value| value.map(&:freeze).freeze }.freeze
  end
end
