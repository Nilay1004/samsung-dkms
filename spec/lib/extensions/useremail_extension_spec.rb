# spec/lib/extensions/useremail_override_spec.rb
require 'rails_helper'

RSpec.describe UserEmail, type: :model do
  let(:email) { "test@example.com" }
  let(:encrypted_email) { "encrypted_test@example.com" }
  let(:hashed_email) { "hashed_test@example.com" }

  before do
    allow(PIIEncryption).to receive(:encrypt_email).and_return(encrypted_email)
    allow(PIIEncryption).to receive(:decrypt_email).and_return(email)
    allow(PIIEncryption).to receive(:hash_email).and_return(hashed_email)
  end

  describe 'callbacks' do
    let(:user_email) { UserEmail.new(email: email) }

    it 'sets temporary email for validation' do
      user_email.email = email
      expect(user_email.send(:set_temporary_email_for_validation)).to eq(email)
    end

    it 'restores encrypted email after validation' do
      user_email.send(:set_temporary_email_for_validation)
      expect(user_email.send(:restore_encrypted_email)).to eq(encrypted_email)
    end

    it 'encrypts email address before save' do
      user_email.save
      expect(user_email.read_attribute(:email)).to eq(encrypted_email)
      expect(user_email.read_attribute(:hashed_email)).to eq(hashed_email)
    end

    it 'encrypts normalized email before save' do
      user_email.normalized_email = email
      user_email.save
      expect(user_email.normalized_email).to eq(encrypted_email)
    end

    it 'decrypts normalized email after find' do
      user_email.save
      user_email.reload
      expect(user_email.normalized_email).to eq(email)
    end
  end

  describe '#email' do
    let(:user_email) { UserEmail.new(email: encrypted_email) }

    it 'returns the decrypted email' do
      expect(user_email.email).to eq(email)
    end
  end

  describe '#email=' do
    let(:user_email) { UserEmail.new }

    it 'sets and encrypts the email' do
      user_email.email = email
      expect(user_email.read_attribute(:email)).to eq(encrypted_email)
      expect(user_email.read_attribute(:hashed_email)).to eq(hashed_email)
    end
  end

  describe '#decrypted_email' do
    let(:user_email) { UserEmail.new(email: encrypted_email) }

    it 'returns the decrypted email' do
      expect(user_email.decrypted_email).to eq(email)
    end
  end
end
