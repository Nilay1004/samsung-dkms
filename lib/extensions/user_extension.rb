# frozen_string_literal: true

class ::User
  def emails
    self.user_emails.order("user_emails.primary DESC NULLS LAST").pluck(:email).map do |encrypted_email|
      PIIEncryption.decrypt_email(encrypted_email)
    end
  end
end
