# frozen_string_literal: true

module ::MyPluginModule
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace MyPluginModule
    config.autoload_paths << File.join(config.root, "lib")
    scheduled_job_dir = "#{config.root}/app/jobs/scheduled"
    config.to_prepare do
      Rails.autoloaders.main.eager_load_dir(scheduled_job_dir) if Dir.exist?(scheduled_job_dir)
    end
  end
end

require_relative "pii_encryption"
require_relative "extensions/user_email_extension"
require_relative "extensions/email_validator_extension"
require_relative "extensions/session_controller_extension"
require_relative "extensions/invite_extension"
require_relative "extensions/email_token_extension"
require_relative "extensions/user_extension"
require_relative "extensions/skipped_email_log_extension"
require_relative "extensions/email_log_extension"