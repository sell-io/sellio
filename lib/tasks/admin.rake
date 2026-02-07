# frozen_string_literal: true

namespace :admin do
  desc "Make a user an admin by email: rake admin:make_admin EMAIL=user@example.com"
  task make_admin: :environment do
    email = ENV["EMAIL"]
    if email.blank?
      puts "Usage: rake admin:make_admin EMAIL=user@example.com"
      exit 1
    end
    user = User.find_by(email: email)
    if user.nil?
      puts "User with email '#{email}' not found."
      exit 1
    end
    user.update_column(:admin, true)
    puts "User #{email} is now an admin."
  end
end
