class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:create, :destroy]

  def create
    @favorite = current_user.favorites.build(listing: @listing)
    
    if @favorite.save
      render json: { status: 'success', favorited: true, favorite_id: @favorite.id }
    else
      render json: { status: 'error', message: 'Could not add to favorites.' }, status: :unprocessable_entity
    end
  end

  def destroy
    @favorite = current_user.favorites.find_by(listing_id: @listing.id)
    if @favorite
      @favorite.destroy
      render json: { status: 'success', favorited: false }
    else
      render json: { status: 'error', message: 'Favorite not found.' }, status: :unprocessable_entity
    end
  end

  def index
    @favorites = current_user.favorite_listings.order(created_at: :desc)
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end
end
