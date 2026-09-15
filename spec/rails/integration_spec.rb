# frozen_string_literal: true

require_relative 'dummy/application'

RSpec.describe 'Rails integration' do
  before(:all) do
    EuEinvoiceTestApplication::Application.initialize!
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  end

  before do
    ActiveRecord::Schema.verbose = false
    ActiveRecord::Schema.define do
      create_table(:invoice_records, force: true, &:timestamps)
      create_table :active_storage_blobs, force: true do |table|
        table.string :key, null: false
        table.string :filename, null: false
        table.string :content_type
        table.text :metadata
        table.string :service_name, null: false
        table.bigint :byte_size, null: false
        table.string :checksum
        table.datetime :created_at, null: false
        table.index :key, unique: true
      end
      create_table :active_storage_attachments, force: true do |table|
        table.string :name, null: false
        table.references :record, polymorphic: true, null: false
        table.references :blob, null: false
        table.datetime :created_at, null: false
      end
    end
  end

  after(:all) do
    ActiveRecord::Base.connection_pool.disconnect!
    directory = EuEinvoiceTestApplication::Application.config.active_storage.service_configurations[:local][:root]
    FileUtils.remove_entry(directory)
  end

  it 'persists and downloads exact artifact bytes through real Active Storage' do
    artifact = EuEinvoice::Artifact.new(bytes: '<invoice/>', content_type: 'application/xml', filename: 'invoice.xml')
    record = InvoiceRecord.create!

    record.invoice.attach(EuEinvoice::Rails::ActiveStorage.attachable(artifact))

    expect(record.reload.invoice.download).to eq(artifact.bytes)
    expect(record.invoice.blob.content_type).to eq(artifact.content_type)
  ensure
    record&.invoice&.purge
    record&.destroy!
  end

  it 'freezes the boot registry and loads companion translations' do
    expect(EuEinvoiceTestApplication::Application.config.eu_einvoice).to be_frozen
    expect(I18n.exists?('eu_einvoice.errors.invalid', :fr)).to be(true)
  end

  it 'reloads application models without retaining their previous class' do
    previous = InvoiceRecord

    EuEinvoiceTestApplication::Application.reloader.reload!

    expect(InvoiceRecord).not_to equal(previous)
    expect(EuEinvoiceTestApplication::Application.config.eu_einvoice).to be_frozen
  end
end
