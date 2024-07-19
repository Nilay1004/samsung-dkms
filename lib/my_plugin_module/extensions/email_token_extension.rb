# frozen_string_literal: true

if defined?(::EmailToken)
  class ::EmailToken
    Rails.logger.info "----------Overrided EmailToken class----------"
    alias_method :original_email=, :email= if method_defined?(:email=)

    def email=(value)
      encrypted_email = PIIEncryption.encrypt_email(value)
      write_attribute(:email, encrypted_email)
    end

    def email
      decrypted_email = PIIEncryption.decrypt_email(read_attribute(:email))
    end
  end
end