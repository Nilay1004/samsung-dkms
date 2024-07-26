module PIIEncryption
  require 'net/http'
  require 'uri'
  require 'json'
  require 'yaml'


  def self.encrypt_email(email)
    return email if email.nil? || email.empty?

    uri = URI.parse("http://35.174.88.137:8080/encrypt")
    response = make_request(uri, { data: email, pii_type: "email" })
    response["encrypted_data"]
  rescue StandardError => e
    Rails.logger.error "PIIEncryption: Error encrypting email: #{e.message}"
    email
  end

  def self.hash_email(email)
    return email if email.nil? || email.empty?

    uri = URI.parse("http://35.174.88.137:8080/hash")
    response = make_request(uri, { data: email, pii_type: "email" })
    response["hashed_data"]
  rescue StandardError => e
    Rails.logger.error "PIIEncryption: Error hashing email: #{e.message}"
    email
  end

  def self.decrypt_email(encrypted_email)
    return encrypted_email if encrypted_email.nil? || encrypted_email.empty?

    uri = URI.parse("http://35.174.88.137:8080/decrypt")
    response = make_request(uri, { data: encrypted_email })
    response["decrypted_data"]
  rescue StandardError => e
    Rails.logger.error "PIIEncryption: Error decrypting email: #{e.message}"
    encrypted_email
  end

  private

  def self.make_request(uri, body)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request.body = body.to_json
    Rails.logger.info "PIIEncryption: Making request to #{uri.path} with body: #{body}"

    response = http.request(request)

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      Rails.logger.error "PIIEncryption: Received non-200 response: #{response.code} #{response.message}"
      {}
    end
  rescue StandardError => e
    Rails.logger.error "PIIEncryption: Request failed: #{e.message}"
    {}
  end
end
