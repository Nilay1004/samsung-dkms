# frozen_string_literal: true

# Adds a new column hashed_email to the user_emails table for storing hashed email data.

class AddTestEmailToUserEmails < ActiveRecord::Migration[6.1]
  def change
    add_column :user_emails, :hashed_email, :string
  end
end