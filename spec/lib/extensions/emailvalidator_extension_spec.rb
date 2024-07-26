# spec/validators/email_validator_spec.rb

require 'rails_helper'

RSpec.describe EmailValidator do
  let(:validator) { EmailValidator.new(attributes: [:email]) }
  let(:user) { User.new }
  let(:user_email) { 'test@example.com' }
  let(:hashed_email) { PIIEncryption.hash_email(user_email) }

  before do
    allow(PIIEncryption).to receive(:hash_email).with(user_email).and_return(hashed_email)
  end

  context 'when the record is new' do
    it 'adds an error if the email is already taken' do
      create(:user_email, email: user_email, hashed_email: hashed_email)

      user.email = user_email
      validator.validate_each(user, :email, user_email)

      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'does not add an error if the email is not taken' do
      user.email = user_email
      validator.validate_each(user, :email, user_email)

      expect(user.errors[:email]).to be_empty
    end
  end

  context 'when the record is not new' do
    it 'does not add an error for existing records' do
      user_email_record = create(:user_email, email: user_email, hashed_email: hashed_email)
      user.email = user_email_record.email
      allow(user).to receive(:new_record?).and_return(false)

      validator.validate_each(user, :email, user_email)

      expect(user.errors[:email]).to be_empty
    end
  end
end
