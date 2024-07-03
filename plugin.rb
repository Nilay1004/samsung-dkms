# frozen_string_literal: true

# name: Samsung DKMS
# about: Encrypt, Decrypt and create Hash of email.
# meta_topic_id: 123
# version: 0.0.1
# authors: Samsung
# url: https://github.com/Nilay1004/discourse-plugin-test-basic
# required_version: 2.7.0

enabled_site_setting :plugin_name_enabled

# frozen_string_literal: true

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


  module ::PIIEncryption
    def self.encrypt_email(email)
      return email if email.nil? || email.empty?

      uri = URI.parse("http://35.174.88.137:8080/encrypt")
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = { data: email, pii_type: "email" }.to_json
      Rails.logger.info "PIIEncryption: Sending encryption request for email: #{email}"
