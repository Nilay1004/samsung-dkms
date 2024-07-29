# frozen_string_literal: true

# This initializer ensures that sensitive information like email addresses is not logged, protecting user privacy and complying with data protection regulations.

Rails.application.config.after_initialize do
    Rails.application.config.filter_parameters += %i[ email ]
end