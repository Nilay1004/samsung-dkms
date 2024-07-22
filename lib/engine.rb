require 'net/http'
require 'uri'
require 'json'

module ::PIIEncryption
  ENCRYPTION_SERVICE_URL = "http://35.174.88.137:8080"

  def self.encrypt_email(email)
    request_to_service("#{ENCRYPTION_SERVICE_URL}/encrypt", email)
  rescue StandardError => e
    Rails.logger.error "Error encrypting email: #{e.message}"
    email
  end

  def self.hash_email(email)
    request_to_service("#{ENCRYPTION_SERVICE_URL}/hash", email)
  rescue StandardError => e
    Rails.logger.error "Error hashing email: #{e.message}"
    email
  end

  def self.decrypt_email(encrypted_email)
    request_to_service("#{ENCRYPTION_SERVICE_URL}/decrypt", encrypted_email)
  rescue StandardError => e
    Rails.logger.error "Error decrypting email: #{e.message}"
    encrypted_email
  end

  def self.request_to_service(url, data)
    return data if data.nil? || data.empty?

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request.body = { data: data, pii_type: "email" }.to_json

    Rails.logger.info "PIIEncryption: Sending request to #{url} for data: #{data}"
    response = http.request(request)
    JSON.parse(response.body)["data"]
  end
end

module ::EncryptedEmail
  class Engine < ::Rails::Engine
    engine_name "encrypted_email"
    isolate_namespace EncryptedEmail
  end

  require_dependency 'user_email'

  class ::UserEmail
    Rails.logger.info "----------Overrided UserEmail class----------"

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
      write_attribute(:test_email, email_hash)
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
      write_attribute(:test_email, email_hash)
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
end
