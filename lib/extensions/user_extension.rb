# frozen_string_literal: true

# This code extends the User class, providing a method emails that returns a list of decrypted email addresses for the user. It retrieves the user's emails from the user_emails table, decrypts them, and orders them with the primary email first.

class ::User
  def emails
    self.user_emails.order("user_emails.primary DESC NULLS LAST").pluck(:email).map do |encrypted_email|
      PIIEncryption.decrypt_email(encrypted_email)
    end
  end
end
