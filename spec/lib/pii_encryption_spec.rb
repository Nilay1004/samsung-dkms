# spec/lib/pii_encryption_spec.rb
require 'rails_helper'

RSpec.describe PIIEncryption do
  let(:email) { "test@example.com" }
  let(:encrypted_email) { "encrypted_test@example.com" }
  let(:hashed_email) { "hashed_test@example.com" }

  before do
    allow(Net::HTTP).to receive(:post).and_return(
      instance_double("Net::HTTPResponse", body: { encrypted_data: encrypted_email, hashed_data: hashed_email, decrypted_data: email }.to_json)
    )
  end

  describe '.encrypt_email' do
    it 'returns the encrypted email' do
      expect(PIIEncryption.encrypt_email(email)).to eq(encrypted_email)
    end

    it 'returns the original email if nil' do
      expect(PIIEncryption.encrypt_email(nil)).to be_nil
    end

    it 'returns the original email if empty' do
      expect(PIIEncryption.encrypt_email("")).to eq("")
    end
  end

  describe '.hash_email' do
    it 'returns the hashed email' do
      expect(PIIEncryption.hash_email(email)).to eq(hashed_email)
    end

    it 'returns the original email if nil' do
      expect(PIIEncryption.hash_email(nil)).to be_nil
    end

    it 'returns the original email if empty' do
      expect(PIIEncryption.hash_email("")).to eq("")
    end
  end

  describe '.decrypt_email' do
    it 'returns the decrypted email' do
      expect(PIIEncryption.decrypt_email(encrypted_email)).to eq(email)
    end

    it 'returns the original email if nil' do
      expect(PIIEncryption.decrypt_email(nil)).to be_nil
    end

    it 'returns the original email if empty' do
      expect(PIIEncryption.decrypt_email("")).to eq("")
    end
  end
end
