# frozen_string_literal: true

# This extension handles the encryption of the email attribute in the invites table, ensuring that the email is stored securely and decrypted only when needed.

require_dependency 'invite'

class ::Invite
  
  before_save do
    self.email = PIIEncryption.encrypt_email(self.email)
  end
  
  def email
    decrypted_email = PIIEncryption.decrypt_email(read_attribute(:email))
    
    decrypted_email
  end
end
