# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @users_count = User.count
      @listings_count = Listing.count
      @banned_count = User.where.not(banned_at: nil).count
      @reports_open_count = Report.open.count
    end
  end
end
