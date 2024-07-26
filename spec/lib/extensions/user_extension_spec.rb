# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#emails' do
    let(:user) { create(:user) }
    let!(:primary_email) { create(:user_email, user: user, email: PIIEncryption.encrypt_email('primary@example.com'), primary: true) }
    let!(:secondary_email) { create(:user_email, user: user, email: PIIEncryption.encrypt_email('secondary@example.com'), primary: false) }

    before do
      allow(PIIEncryption).to receive(:decrypt_email).and_call_original
    end

    it 'decrypts and returns emails ordered with primary first' do
      emails = user.emails
      expect(emails).to eq(['primary@example.com', 'secondary@example.com'])
    end

    it 'orders emails with primary emails first' do
      # Ensure ordering is correct
      expect(user.user_emails.order("user_emails.primary DESC NULLS LAST").pluck(:email)).to eq([primary_email.email, secondary_email.email])
    end

    context 'when there are no emails' do
      before do
        user.user_emails.destroy_all
      end

      it 'returns an empty array' do
        expect(user.emails).to be_empty
      end
    end

    context 'when there are only primary emails' do
      before do
        user.user_emails.where.not(id: primary_email.id).destroy_all
      end

      it 'returns the primary email' do
        expect(user.emails).to eq(['primary@example.com'])
      end
    end

    context 'when there are only secondary emails' do
      before do
        user.user_emails.where.not(id: secondary_email.id).destroy_all
      end

      it 'returns the secondary email' do
        expect(user.emails).to eq(['secondary@example.com'])
      end
    end
  end
end
