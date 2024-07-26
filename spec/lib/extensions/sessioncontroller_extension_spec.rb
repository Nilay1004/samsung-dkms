# spec/controllers/session_controller_spec.rb

require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  describe 'POST #create' do
    let(:email) { 'test@example.com' }
    let(:username) { 'testuser' }
    let(:hashed_email) { PIIEncryption.hash_email(email) }
    let(:user) { create(:user, username: username) }
    let!(:user_email) { create(:user_email, user: user, email: email, hashed_email: hashed_email) }

    before do
      allow(PIIEncryption).to receive(:hash_email).with(email).and_return(hashed_email)
    end

    context 'when login param is present' do
      it 'hashes the email and finds the user by hashed email' do
        post :create, params: { login: email }

        expect(PIIEncryption).to have_received(:hash_email).with(email)
        expect(UserEmail).to exist(hashed_email: hashed_email)
      end

      it 'replaces params[:login] with the username if user is found' do
        post :create, params: { login: email }

        expect(assigns(:params)[:login]).to eq(username)
      end
    end

    context 'when login param is not present' do
      it 'calls the original create method without changes' do
        expect_any_instance_of(SessionController).to receive(:original_create)

        post :create, params: {}
      end
    end

    context 'when user is not found by hashed email' do
      it 'does not change params[:login]' do
        post :create, params: { login: 'nonexistent@example.com' }

        expect(assigns(:params)[:login]).to eq('nonexistent@example.com')
      end
    end
  end
end
