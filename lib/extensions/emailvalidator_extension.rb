# frozen_string_literal: true

# This extension overrides the email validation to use the hashed email for uniqueness checks. It hashes the email and checks if a record with the same hashed email already exists, adding an error if it does.

# Override UserEmail uniqueness validation to use hashed email
class ::EmailValidator
  
  def validate_each(record, attribute, value)
    if record.new_record?
      email_hash = PIIEncryption.hash_email(value)
      
      if UserEmail.where(hashed_email: email_hash).exists?
        
        record.errors.add(attribute, :taken)
      else
        
      end
    end
  end
end
