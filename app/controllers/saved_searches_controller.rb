class SavedSearchesController < ApplicationController
  before_action :authenticate_user!

  def index
    @saved_searches = current_user.saved_searches.order(created_at: :desc)
  end

  def create
    # Permitted query params from listings index
    query_params = params.permit(
      :search, :location, :category_id, :subcategory,
      :make, :model, :min_year, :max_year, :min_mileage, :max_mileage,
      :min_price, :max_price, :include_sold, :page
    ).to_h
    query_params.delete("page") # don't persist page
    query_params.delete("name")
    query_params = query_params.compact_blank

    name = params[:name].presence || "Saved search"
    @saved_search = current_user.saved_searches.build(name: name, query_params: query_params)

    if @saved_search.save
      redirect_back fallback_location: listings_path, notice: "Search saved."
    else
      redirect_back fallback_location: listings_path, alert: @saved_search.errors.full_messages.join(", ")
    end
  end

  def destroy
    @saved_search = current_user.saved_searches.find(params[:id])
    @saved_search.destroy!
    redirect_to my_saved_searches_path, notice: "Saved search removed."
  end
end
