# frozen_string_literal: true


# Override UserEmail uniqueness validation to use hashed email
class ::EmailValidator
  
  def validate_each(record, attribute, value)
    if record.new_record?
      email_hash = PIIEncryption.hash_email(value)
      
      if UserEmail.where(test_email: email_hash).exists?
        
        record.errors.add(attribute, :taken)
      else
        
      end
    end
  end
end
