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


Configuration
Settings
samsung_dkms_plugin_enabled: Enables or disables the plugin.
service_url: Specifies the URL of the service used for encryption and decryption.
These settings can be configured in the config/settings.yml file or through the Discourse admin panel.

Security
This plugin filters sensitive parameters, such as email addresses, from being logged in plain text. It uses a custom encryption service specified by the service_url setting.

Usage
The plugin extends several Discourse models to handle encryption and decryption:

EmailLog: Encrypts to_address before saving and decrypts after initialization.
EmailToken: Encrypts the email attribute before saving and decrypts when retrieved.
Invite: Encrypts the email before saving and decrypts when retrieved.
SkippedEmailLog: Similar to EmailLog, handles encryption and decryption of to_address.
UserEmail: Handles encryption, decryption, and hashing of the email attribute.
User: Decrypts and returns user emails, ensuring primary emails are ordered first.
EmailValidator: Validates the uniqueness of email addresses by using their hashed versions.
SessionController: Overridden to handle login using hashed email addresses.
Development and Testing
The plugin includes a set of RSpec tests to ensure the integrity of the encryption and decryption processes. To run the tests:

Development and Testing
The plugin includes a set of RSpec tests to ensure the integrity of the encryption and decryption processes. To run the tests:

Navigate to the plugin directory.
Run the RSpec tests:

bundle exec rspec

Contributing
Contributions are welcome! Please follow the standard GitHub fork-and-pull workflow:

1. Fork the repository.
2. Create a new feature branch.
3. Commit your changes.
4. Push to your branch.
5. Create a pull request.