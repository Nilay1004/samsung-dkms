# frozen_string_literal: true

# name: Samsung DKMS PLUGIN
# about: This plugin encrypt all the emails present in discouse DB and discourse logs.
# meta_topic_id: 001
# version: 0.0.1
# authors: Pankaj
# url: https://github.com/Nilay1004/discourse-plugin-test-basic
# required_version: 2.7.0

enabled_site_setting :plugin_name_enabled

require_relative "lib/engine"
require_relative "lib/pii_encryption"
require_relative "lib/user_email_extension"

after_initialize do
  Rails.logger.info "simple_user_email_override: Plugin initialized"
end



  