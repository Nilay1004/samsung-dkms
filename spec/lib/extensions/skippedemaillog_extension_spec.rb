# spec/models/skipped_email_log_spec.rb

require 'rails_helper'

RSpec.describe SkippedEmailLog, type: :model do
  let(:email) { 'test@example.com' }
  let(:encrypted_email) { PIIEncryption.encrypt_email(email) }
  let(:skipped_email_log) { SkippedEmailLog.new(to_address: email) }

  before do
    allow(PIIEncryption).to receive(:encrypt_email).with(email).and_return(encrypted_email)
    allow(PIIEncryption).to receive(:decrypt_email).with(encrypted_email).and_return(email)
  end

  describe 'before_save callback' do
    it 'encrypts the to_address before saving' do
      skipped_email_log.save
      expect(skipped_email_log.read_attribute(:to_address)).to eq(encrypted_email)
    end
  end

  describe 'after_initialize callback' do
    it 'decrypts the to_address after initialization' do
      skipped_email_log = SkippedEmailLog.new(to_address: encrypted_email)
      skipped_email_log.save
      expect(skipped_email_log.instance_variable_get(:@decrypted_to_address)).to eq(email)
    end
  end

  describe '#to_address' do
    it 'returns the decrypted email address' do
      skipped_email_log.save
      expect(skipped_email_log.to_address).to eq(email)
    end
  end

  describe '#to_address=' do
    it 'sets the decrypted email address and encrypts it' do
      new_email = 'new_test@example.com'
      new_encrypted_email = PIIEncryption.encrypt_email(new_email)
      allow(PIIEncryption).to receive(:encrypt_email).with(new_email).and_return(new_encrypted_email)
      
      skipped_email_log.to_address = new_email
      
      expect(skipped_email_log.instance_variable_get(:@decrypted_to_address)).to eq(new_email)
      expect(skipped_email_log.read_attribute(:to_address)).to eq(new_encrypted_email)
    end
  end

  describe 'encryption and decryption' do
    it 'correctly encrypts and decrypts the email address' do
      skipped_email_log.save
      reloaded_skipped_email_log = SkippedEmailLog.find(skipped_email_log.id)
      expect(reloaded_skipped_email_log.to_address).to eq(email)
    end
  end
end
