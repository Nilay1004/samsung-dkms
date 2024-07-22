# frozen_string_literal: true

# name: Samsung DKMS PLUGIN
# about: This plugin encrypt all the emails present in discouse DB and discourse logs.
# meta_topic_id: 001
# version: 0.0.1
# authors: Pankaj
# url: https://github.com/Nilay1004/discourse-plugin-test-basic
# required_version: 2.7.0

enabled_site_setting :plugin_name_enabled

# Avoid defining constants multiple times
unless defined?(::MyPluginModule)
  module ::MyPluginModule
    PLUGIN_NAME = "Samsung DKMS PLUGIN"
  end
end

require_relative "lib/my_plugin_module/engine"
require_relative "lib/my_plugin_module/pii_encryption"

after_initialize do
  Rails.logger.info "PIIEncryption: Plugin initialized"

  # Load extensions
  extensions_path = File.expand_path('../lib/my_plugin_module/extensions/*.rb', __FILE__)
  Dir.glob(extensions_path).each do |file|
    require_relative file
  end
end



  