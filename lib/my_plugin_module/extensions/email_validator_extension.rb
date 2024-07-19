# frozen_string_literal: true

class ::EmailValidator
  Rails.logger.info "----------Overridden EmailValidator class----------"
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
