module PIIEncryption
  API_URL = "http://35.174.88.137:8080"
  CONTENT_TYPE = 'application/json'

  def self.encrypt_email(email)
    handle_pii_request("#{API_URL}/encrypt", email, "encrypting")
  end

  def self.hash_email(email)
    handle_pii_request("#{API_URL}/hash", email, "hashing")
  end

  def self.decrypt_email(encrypted_email)
    handle_pii_request("#{API_URL}/decrypt", encrypted_email, "decrypting")
  end

  private

  def self.handle_pii_request(uri, data, action)
    return data if data.nil? || data.empty?

    http = Net::HTTP.new(URI.parse(uri).host, URI.parse(uri).port)
    request = Net::HTTP::Post.new(URI.parse(uri).path, 'Content-Type' => CONTENT_TYPE)
    request.body = { data: data }.to_json

    Rails.logger.info "PIIEncryption: Sending #{action} request for data: #{data}"

    begin
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        response_data = JSON.parse(response.body)["#{action == "decrypting" ? "decrypted_data" : "encrypted_data" || "hashed_data"}"]
        Rails.logger.info "PIIEncryption: #{action.capitalize} successful: #{response_data}"
        response_data
      else
        handle_error(response, action, data)
      end
    rescue StandardError => e
      Rails.logger.error "Error #{action} data: #{e.message}"
      data
    end
  end

  def self.handle_error(response, action, data)
    Rails.logger.error "PIIEncryption: Failed to #{action} data. HTTP Status: #{response.code}, Message: #{response.message}"
    data
  end
end
