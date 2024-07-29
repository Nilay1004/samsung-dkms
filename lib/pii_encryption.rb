
# This module defines methods for encrypting, hashing, and decrypting emails. It sends HTTP requests to a samsung dkms service for these operations and handles errors and logging.

module PIIEncryption
  API_URL = SiteSetting.service_url
  CONTENT_TYPE = 'application/json'

  def self.encrypt_email(email)
    handle_pii_request("#{API_URL}/encrypt", email, 'email', "encrypted_data")
  end

  def self.hash_email(email)
    handle_pii_request("#{API_URL}/hash", email, 'email', "hashed_data")
  end

  def self.decrypt_email(encrypted_email)
    handle_pii_request("#{API_URL}/decrypt", encrypted_email, 'email', "decrypted_data")
  end

  private

  def self.handle_pii_request(uri, data, pii_type, response_key)
    return data if data.nil? || data.empty?

    http = Net::HTTP.new(URI.parse(uri).host, URI.parse(uri).port)
    request = Net::HTTP::Post.new(URI.parse(uri).path, 'Content-Type' => CONTENT_TYPE)
    request.body = { data: data, pii_type: pii_type }.to_json

    Rails.logger.info "PIIEncryption: Sending #{response_key} request."

    begin
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        response_data = JSON.parse(response.body)[response_key]
        Rails.logger.info "PIIEncryption: Request successful: #{response_data}"
        response_data
      else
        handle_error(response, uri, data)
      end
    rescue StandardError => e
      Rails.logger.error "Error processing data: #{e.message}"
      data
    end
  end

  def self.handle_error(response, uri, data)
    Rails.logger.error "PIIEncryption: Failed to process request to #{uri}. HTTP Status: #{response.code}, Message: #{response.message}"
    data
  end
end
