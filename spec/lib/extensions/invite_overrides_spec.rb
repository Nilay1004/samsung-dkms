# spec/models/invite_spec.rb

require 'rails_helper'

RSpec.describe Invite, type: :model do
  let(:email) { 'test@example.com' }
  let(:encrypted_email) { PIIEncryption.encrypt_email(email) }
  let(:invite) { Invite.new(email: email) }

  before do
    allow(PIIEncryption).to receive(:encrypt_email).with(email).and_return(encrypted_email)
    allow(PIIEncryption).to receive(:decrypt_email).with(encrypted_email).and_return(email)
  end

  describe 'before_save callback' do
    it 'encrypts the email before saving' do
      invite.save
      expect(invite.read_attribute(:email)).to eq(encrypted_email)
    end
  end

  describe '#email' do
    it 'decrypts the email when retrieved' do
      invite.write_attribute(:email, encrypted_email)
      expect(invite.email).to eq(email)
    end
  end

  describe 'encryption and decryption' do
    it 'correctly encrypts and decrypts the email' do
      invite.save
      reloaded_invite = Invite.find(invite.id)
      expect(reloaded_invite.email).to eq(email)
    end
  end
end
