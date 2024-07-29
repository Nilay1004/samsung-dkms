# frozen_string_literal: true

# This extension for the SessionController intercepts the login process. It hashes the login parameter (email), finds the corresponding user by the hashed email, and replaces the login parameter with the username if the user exists. This integration helps maintain email privacy during authentication.

require_dependency 'session_controller'

class ::SessionController
  
  alias_method :original_create, :create

  def create
    if params[:login].present?
      email_hash = ::PIIEncryption.hash_email(params[:login])
      
      user_email_record = UserEmail.find_by(hashed_email: email_hash)
      if user_email_record
        user = User.find(user_email_record.user_id)
        params[:login] = user.username
      end
    end
    original_create
  end
end
