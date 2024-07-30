# frozen_string_literal: true

# name: samsung-dkms
# about: This plugin encrypt all the emails present in discouse DB and discourse logs.
# meta_topic_id: 001
# version: 0.0.1
# authors: Pankaj
# url: https://github.com/Nilay1004/samsung-dkms/blob/main/README.md
# required_version: 2.7.0

enabled_site_setting :samsung_dkms_plugin_enabled

unless defined?(::MyPluginModule)
  module ::MyPluginModule
    PLUGIN_NAME = "samsung-dkms"
  end
end

# Loads the extensions defined in the lib/extensions directory.
require_relative "lib/pii_encryption"

after_initialize do
  Rails.logger.info "PIIEncryption: Plugin initialized"
  
  require_relative 'lib/extensions/emaillog_extension'
  require_relative 'lib/extensions/emailtoken_extension'
  require_relative 'lib/extensions/emailvalidator_extension'
  require_relative 'lib/extensions/invite_extension'
  require_relative 'lib/extensions/sessioncontroller_extension'
  require_relative 'lib/extensions/skippedemaillog_extension'
  require_relative 'lib/extensions/user_extension'
  require_relative 'lib/extensions/useremail_extension'

end



  