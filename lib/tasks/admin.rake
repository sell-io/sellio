# frozen_string_literal: true

namespace :admin do
  # Run this on production (e.g. bin/kamal app exec 'bin/rails admin:setup') so admin login works.
  # Uses ADMIN_EMAIL and ADMIN_PASSWORD from ENV, or defaults.
  desc "Create or reset admin user so login works (for production). Uses ENV ADMIN_EMAIL, ADMIN_PASSWORD or defaults."
  task setup: :environment do
    email = ENV["ADMIN_EMAIL"].presence || ENV["EMAIL"].presence || "alexsidorov2005@gmail.com"
    password = ENV["ADMIN_PASSWORD"].presence || ENV["PASSWORD"].presence || "Dr3amH0useEleven"
    user = User.find_or_create_by(email: email) do |u|
      u.password = password
      u.password_confirmation = password
      u.name = "Admin"
      u.location = "Ireland"
    end
    user.password = password
    user.password_confirmation = password
    user.admin = true
    user.banned_at = nil
    user.name = "Admin" if user.name.blank?
    user.save(validate: false)
    puts "Admin ready: #{email} (admin=#{user.admin}, banned=#{user.banned_at.inspect})"
  end

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
