# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # Block banned users from signing in
  def create
    email = params.dig(:user, :email)
    user = email.present? ? User.find_by(email: email) : nil
    if user&.banned?
      flash[:alert] = "This account has been banned. Please contact support."
      redirect_to new_user_session_path and return
    end
    super
  end
end
