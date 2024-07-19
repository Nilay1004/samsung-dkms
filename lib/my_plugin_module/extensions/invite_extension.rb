# frozen_string_literal: true

class ::Invite
  Rails.logger.info "----------Overridden Invite class----------"
  before_save do
    self.email = PIIEncryption.encrypt_email(self.email)
  end
  
  def email
    decrypted_email = PIIEncryption.decrypt_email(read_attribute(:email))
    Rails.logger.info("Decrypted Email: #{decrypted_email}")
    decrypted_email
  end
end
