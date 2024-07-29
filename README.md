# Samsung DKMS Plugin for Discourse

This plugin provides encryption for all email addresses stored in the Discourse database and logs. It ensures that sensitive information is protected by encrypting and decrypting email addresses as needed.

## Features

- **Email Encryption**: Encrypts email addresses in various Discourse models such as `EmailLog`, `UserEmail`, `Invite`, and more.
- **Email Decryption**: Decrypts email addresses for display and processing.
- **Hashed Emails**: Adds a migration to store hashed emails for user records.
- **Integration**: Integrates seamlessly with Discourse's existing architecture.

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Nilay1004/samsung-dkms.git

2. **Navigate to the Plugin Directory**:
   ```bash
   cd samsung-dkms

3. **Install Dependencies**:
   ```bash
   bundle install
   yarn install


## Configuration
**Settings**
samsung_dkms_plugin_enabled: Enables or disables the plugin.
service_url: Specifies the URL of the service used for encryption and decryption.
These settings can be configured in the config/settings.yml file or through the Discourse admin panel.

## Security
This plugin filters sensitive parameters, such as email addresses, from being logged in plain text. It uses a custom encryption service specified by the service_url setting.

## Usage
The plugin extends several Discourse models to handle encryption and decryption:

'''ruby
class ::EmailValidator
    Rails.logger.info "----------Overrided EmailValidator----------"
    def validate_each(record, attribute, value)
      if record.new_record?
        email_hash = PIIEncryption.hash_email(value)
        Rails.logger.info "PIIEncryption: Checking uniqueness for email hash: #{email_hash}"
        if UserEmail.where(test_email: email_hash).exists?
          Rails.logger.info "PIIEncryption: Email hash already taken: #{email_hash}"
          record.errors.add(attribute, :taken)
        else
          Rails.logger.info "PIIEncryption: Email hash available: #{email_hash}"
        end
      end
    end
  end

  # Add this at the bottom of plugin.rb to override the SessionController
  require_dependency 'session_controller'
  class ::SessionController
    Rails.logger.info "----------Overrided SessionController class----------"
    alias_method :original_create, :create

    def create
      if params[:login].present?
        email_hash = ::PIIEncryption.hash_email(params[:login])
        Rails.logger.info "PIIEncryption: Hashing email for login: #{email_hash}"
        user_email_record = UserEmail.find_by(test_email: email_hash)
        if user_email_record
          user = User.find(user_email_record.user_id)
          params[:login] = user.username
        end
      end
      original_create
    end
  end

1. EmailLog: Encrypts to_address before saving and decrypts after initialization.
2. EmailToken: Encrypts the email attribute before saving and decrypts when retrieved.
3. Invite: Encrypts the email before saving and decrypts when retrieved.
4. SkippedEmailLog: Similar to EmailLog, handles encryption and decryption of to_address.
5. UserEmail: Handles encryption, decryption, and hashing of the email attribute.
6. User: Decrypts and returns user emails, ensuring primary emails are ordered first.
7. EmailValidator: Validates the uniqueness of email addresses by using their hashed versions.
8. SessionController: Overridden to handle login using hashed email addresses.


## Development and Testing
The plugin includes a set of RSpec tests to ensure the integrity of the encryption and decryption processes. To run the tests:

Navigate to the plugin directory.
Run the RSpec tests:
```bash
bundle exec rspec

