# frozen_string_literal: true

# name: encryption decryption
# about: Encrypt email before save in DB
# meta_topic_id: 123
# version: 0.0.1
# authors: Pankaj
# url: https://github.com/Nilay1004/discourse-plugin-test-basic
# required_version: 2.7.0

enabled_site_setting :plugin_name_enabled

# Avoid defining constants multiple times
unless defined?(::MyPluginModule)
  module ::MyPluginModule
    PLUGIN_NAME = "discourse-plugin-name-darshan"
  end
end

require_relative "lib/my_plugin_module/engine"


require 'net/http'
require 'uri'
require 'json'

after_initialize do
  Rails.logger.info "PIIEncryption: Plugin initialized"
  require_dependency 'user_email'
  require_dependency 'auth/default_current_user_provider'
  require_dependency 'invite'
  require_dependency 'invite_redeemer'


  module ::PIIEncryption
    def self.encrypt_email(email)
      return email if email.nil? || email.empty?

      uri = URI.parse("http://35.174.88.137:8080/encrypt")
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = { data: email, pii_type: "email" }.to_json
      Rails.logger.info "PIIEncryption: Sending encryption request for email: #{email}"
      response = http.request(request)

      encrypted_email = JSON.parse(response.body)["encrypted_data"]
      Rails.logger.info "PIIEncryption: Encrypted email: #{encrypted_email}"
      encrypted_email
    rescue StandardError => e
      Rails.logger.error "Error encrypting email: #{e.message}"
      email
    end

    def self.hash_email(email)
      return email if email.nil? || email.empty?

      uri = URI.parse("http://35.174.88.137:8080/hash")
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = { data: email, pii_type: "email" }.to_json
      Rails.logger.info "PIIEncryption: Sending hash request for email: #{email}"
      response = http.request(request)

      email_hash = JSON.parse(response.body)["hashed_data"]
      Rails.logger.info "PIIEncryption: Email hash: #{email_hash}"
      email_hash
    rescue StandardError => e
      Rails.logger.error "Error hashing email: #{e.message}"
      email
    end

    def self.decrypt_email(encrypted_email)
      return encrypted_email if encrypted_email.nil? || encrypted_email.empty?

      uri = URI.parse("http://35.174.88.137:8080/decrypt")
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = { data: encrypted_email }.to_json
      Rails.logger.info "PIIEncryption: Sending decryption request for encrypted email: #{encrypted_email}"
      response = http.request(request)

      decrypted_email = JSON.parse(response.body)["decrypted_data"]
      Rails.logger.info "PIIEncryption: Decrypted email: #{decrypted_email}"
      decrypted_email
    rescue StandardError => e
      Rails.logger.error "Error decrypting email: #{e.message}"
      encrypted_email
    end
  end

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



  # Override UserEmail uniqueness validation to use hashed email
  class ::EmailValidator
    def validate_each(record, attribute, value)
      if record.new_record?
        email_hash = PIIEncryption.hash_email(value)
        Rails.logger.info "PIIEncryption: Checking uniqueness for email hash: #{email_hash}"
        if UserEmail.where(test_email: email_hash).exists?
          Rails.logger.info "PIIEncryption: Email hash already taken: #{email_hash}"
          record.errors.add(attribute, :taken)
        else
          Rails.logger.info "PIIEncryption: Email hash available: #{email_hash}"
        end
      end
    end
  end

  # Add this at the bottom of plugin.rb to override the SessionController
  require_dependency 'session_controller'
  class ::SessionController
    alias_method :original_create, :create

    def create
      if params[:login].present?
        email_hash = ::PIIEncryption.hash_email(params[:login])
        Rails.logger.info "PIIEncryption: Hashing email for login: #{email_hash}"
        user_email_record = UserEmail.find_by(test_email: email_hash)
        if user_email_record
          user = User.find(user_email_record.user_id)
          params[:login] = user.username
        end
      end
      original_create
    end
  end


  class ::Invite

    before_save do
      self.email = PIIEncryption.encrypt_email(self.email)
    end
    
    def email
      decrypted_email = PIIEncryption.decrypt_email(read_attribute(:email))
      Rails.logger.info("Decrypted Email: #{decrypted_email}")
      decrypted_email
    end
  end

  class ::EmailToken
    alias_method :original_email=, :email=
    alias_method :original_email, :email

    def email=(value)
      self[:email] = PIIEncryption.encrypt_email(value)
    end

    def email
      PIIEncryption.decrypt_email(self[:email])
    end
  end
end



  