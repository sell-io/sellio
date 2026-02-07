# frozen_string_literal: true

module Admin
  class ListingsController < BaseController
    def index
      per = 20
      page = [params[:page].to_i, 1].max
      @listings = Listing.includes(:user, :category).order(created_at: :desc).limit(per).offset((page - 1) * per)
      @listings_total = Listing.count
      @listings_total_pages = (@listings_total.to_f / per).ceil
      @listings_current_page = page
    end

    def destroy
      @listing = Listing.find(params[:id])
      @listing.destroy
      flash[:notice] = "Listing has been deleted."
      redirect_to admin_listings_path
    end
  end
end
