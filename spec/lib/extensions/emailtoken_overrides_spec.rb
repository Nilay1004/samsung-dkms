# spec/models/email_token_spec.rb

require 'rails_helper'

RSpec.describe EmailToken, type: :model do
  let(:email) { 'test@example.com' }
  let(:encrypted_email) { PIIEncryption.encrypt_email(email) }
  let(:email_token) { EmailToken.new(email: email) }

  before do
    allow(PIIEncryption).to receive(:encrypt_email).with(email).and_return(encrypted_email)
    allow(PIIEncryption).to receive(:decrypt_email).with(encrypted_email).and_return(email)
  end

  describe '#email=' do
    it 'encrypts the email before saving' do
      email_token.email = email
      expect(email_token.read_attribute(:email)).to eq(encrypted_email)
    end
  end

  describe '#email' do
    it 'decrypts the email when retrieved' do
      email_token.write_attribute(:email, encrypted_email)
      expect(email_token.email).to eq(email)
    end
  end

  describe 'alias_method :original_email=' do
    it 'preserves the original email setter method' do
      expect(email_token).to respond_to(:original_email=)
    end

    it 'allows setting email using the original email setter' do
      email_token.original_email = email
      expect(email_token.read_attribute(:email)).to eq(email)
    end
  end

  describe 'encryption and decryption' do
    it 'correctly encrypts and decrypts the email' do
      email_token.email = email
      email_token.save
      reloaded_email_token = EmailToken.find(email_token.id)
      expect(reloaded_email_token.email).to eq(email)
    end
  end
end
