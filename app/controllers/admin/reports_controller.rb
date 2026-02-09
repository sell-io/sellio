# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    def index
      @reports = Report.includes(:listing, :user).order(created_at: :desc)
      @open_count = Report.open.count
    end

    def show
      @report = Report.find(params[:id])
    end

    def resolve
      @report = Report.find(params[:id])
      @report.update!(status: "resolved")
      redirect_to admin_reports_path, notice: "Report marked as resolved."
    end
  end
end
