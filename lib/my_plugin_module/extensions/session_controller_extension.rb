# frozen_string_literal: true

require_dependency 'session_controller'

class ::SessionController
  Rails.logger.info "----------Overridden SessionController class----------"
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
