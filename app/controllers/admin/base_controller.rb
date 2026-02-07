# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    layout "admin"

    private

    def require_admin
      return if current_user&.admin?

      flash[:alert] = "You are not authorized to access this area."
      redirect_to root_path
    end
  end
end
