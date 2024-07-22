# frozen_string_literal: true

class ::Invite
  
  before_save do
    self.email = PIIEncryption.encrypt_email(self.email)
  end
  
  def email
    decrypted_email = PIIEncryption.decrypt_email(read_attribute(:email))
    
    decrypted_email
  end
end
