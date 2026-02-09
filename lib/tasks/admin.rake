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
    user.update_columns(admin: true, banned_at: nil)
    puts "User #{email} is now an admin."
  end

  desc "Reset admin password so you can log in: rake admin:reset_password EMAIL=alexsidorov2005@gmail.com PASSWORD=Dr3amH0useEleven"
  task reset_password: :environment do
    email = ENV["EMAIL"] || "alexsidorov2005@gmail.com"
    password = ENV["PASSWORD"] || "Dr3amH0useEleven"
    user = User.find_by(email: email)
    if user.nil?
      puts "User with email '#{email}' not found."
      exit 1
    end
    user.password = password
    user.password_confirmation = password
    user.banned_at = nil
    user.admin = true
    user.save(validate: false)
    puts "Password and admin reset for #{email}. You can log in with that password now."
  end
end
