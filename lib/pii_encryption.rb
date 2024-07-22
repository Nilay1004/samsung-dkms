# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module PIIEncryption
  def self.encrypt_email(email)
    return email if email.nil? || email.empty?

    uri = URI.parse("http://35.174.88.137:8080/encrypt")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request.body = { data: email, pii_type: "email" }.to_json
    
    response = http.request(request)

    encrypted_email = JSON.parse(response.body)["encrypted_data"]
    
    encrypted_email
  rescue StandardError => e
    
    email
  end

  def self.hash_email(email)
    return email if email.nil? || email.empty?

    uri = URI.parse("http://35.174.88.137:8080/hash")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request.body = { data: email, pii_type: "email" }.to_json
    
    response = http.request(request)

    email_hash = JSON.parse(response.body)["hashed_data"]
    
    email_hash
  rescue StandardError => e
    
    email
  end

  def self.decrypt_email(encrypted_email)
    return encrypted_email if encrypted_email.nil? || encrypted_email.empty?

    uri = URI.parse("http://35.174.88.137:8080/decrypt")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request.body = { data: encrypted_email }.to_json
   
    response = http.request(request)

    decrypted_email = JSON.parse(response.body)["decrypted_data"]
    
    decrypted_email
  rescue StandardError => e
    
    encrypted_email
  end
end
