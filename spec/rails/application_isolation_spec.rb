# frozen_string_literal: true

require 'open3'
require 'rbconfig'

RSpec.describe 'Application invoice configuration isolation' do
  it 'keeps clients distinct through two real application boots and a reload' do
    output, status = Open3.capture2e(RbConfig.ruby, File.expand_path('dummy/multiple_applications.rb', __dir__))

    expect(status.success?).to be(true), output
  end
end
