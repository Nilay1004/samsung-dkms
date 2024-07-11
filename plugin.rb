# frozen_string_literal: true

# name: encryption decryption
# about: Encrypt email before save in DB
# meta_topic_id: 123
# version: 0.0.1
# authors: Pankaj
# url: https://github.com/Nilay1004/discourse-plugin-test-basic
# required_version: 2.7.0

enabled_site_setting :plugin_name_enabled

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
  
end



  