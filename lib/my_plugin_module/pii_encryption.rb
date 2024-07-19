# frozen_string_literal: true

module PIIEncryption
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
