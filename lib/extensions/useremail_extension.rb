# frozen_string_literal: true

# Encrypts and hashes the email before saving it to the user_emails table.
# Ensures that the normalized_email is also encrypted.
# Provides methods to decrypt emails when accessing the email and normalized_email attributes.
# It includes validation steps to handle email encryption and decryption during validation processes.

require_dependency 'user_email'

class ::UserEmail
  
  before_validation :set_temporary_email_for_validation, if: :email_changed?
  after_validation :restore_encrypted_email, if: :email_changed?

  before_save :encrypt_email_address, if: :email_changed?
  before_save :encrypt_normalized_email
  after_find :decrypt_normalized_email

  def email
    @decrypted_email ||= PIIEncryption.decrypt_email(read_attribute(:email))
  end

  def email=(value)
    @decrypted_email = value
    encrypted_email = PIIEncryption.encrypt_email(value)
    email_hash = PIIEncryption.hash_email(value)
    write_attribute(:email, encrypted_email)
    write_attribute(:hashed_email, email_hash)
  end

  def decrypted_email
    PIIEncryption.decrypt_email(read_attribute(:email))
  end

  private

  def set_temporary_email_for_validation
    @original_email = read_attribute(:email)
    write_attribute(:email, @decrypted_email)
  end

  def restore_encrypted_email
    write_attribute(:email, @original_email)
  end

  def encrypt_email_address
    encrypted_email = PIIEncryption.encrypt_email(@decrypted_email)
    email_hash = PIIEncryption.hash_email(@decrypted_email)
    write_attribute(:email, encrypted_email)
    write_attribute(:hashed_email, email_hash)
  end

  def encrypt_normalized_email
    if self.normalized_email.present?
      self.normalized_email = PIIEncryption.encrypt_email(self.normalized_email.downcase.strip)
    end
  end

  def decrypt_normalized_email
    if self.normalized_email.present?
      self.normalized_email = PIIEncryption.decrypt_email(self.normalized_email)
    end
  end
end