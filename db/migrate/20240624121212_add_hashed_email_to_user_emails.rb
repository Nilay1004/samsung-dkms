# frozen_string_literal: true

class AddTestEmailToUserEmails < ActiveRecord::Migration[6.1]
  def change
    add_column :user_emails, :hashed_email, :string
  end
end