# frozen_string_literal: true

# name: Samsung DKMS PLUGIN
# about: This plugin encrypt all the emails present in discouse DB and discourse logs.
# meta_topic_id: 001
# version: 0.0.1
# authors: Pankaj
# url: https://github.com/Nilay1004/discourse-plugin-test-basic
# required_version: 2.7.0

enabled_site_setting :samsung_dkms_plugin_enabled

unless defined?(::MyPluginModule)
  module ::MyPluginModule
    PLUGIN_NAME = "discourse-plugin-name-darshan"
  end
end

require_relative "lib/pii_encryption"

after_initialize do
  Rails.logger.info "PIIEncryption: Plugin initialized"
  require_relative 'config/initializers/email_overrides'
end



  