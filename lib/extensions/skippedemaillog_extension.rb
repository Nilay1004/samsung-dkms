# frozen_string_literal: true

# This code ensures that email addresses in the skipped_email_logs table are encrypted before saving and decrypted when accessed.

class ::SkippedEmailLog
  
    
  before_save :encrypt_to_address
  after_initialize :decrypt_to_address

  def to_address
    @decrypted_to_address ||= PIIEncryption.decrypt_email(read_attribute(:to_address))
  end

  def to_address=(value)
    @decrypted_to_address = value
    encrypted_to_address = PIIEncryption.encrypt_email(value)
    write_attribute(:to_address, encrypted_to_address)
  end

  private

  def encrypt_to_address
    if @decrypted_to_address.present?
      encrypted_to_address = PIIEncryption.encrypt_email(@decrypted_to_address)
      write_attribute(:to_address, encrypted_to_address)
    end
  end

  def decrypt_to_address
    if read_attribute(:to_address).present?
      @decrypted_to_address = PIIEncryption.decrypt_email(read_attribute(:to_address))
    end
  end
end