class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @listing = Listing.find(params[:listing_id])
    @report = Report.new(listing: @listing)
  end

  def create
    @listing = Listing.find(params[:report][:listing_id])
    @report = current_user.reports.build(report_params)
    @report.listing = @listing

    if @report.save
      redirect_to @listing, notice: "Thank you. Your report has been submitted and we'll look into it."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def report_params
    params.require(:report).permit(:reason, :body)
  end
end
