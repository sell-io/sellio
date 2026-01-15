class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  # GET /users/1
  def show
    @listings = @user.listings.order(created_at: :desc)
    @reviews = @user.reviews_received.includes(:reviewer).order(created_at: :desc)
    @user_review = current_user&.reviews_given&.find_by(reviewed_user: @user) if user_signed_in?
    @review = Review.new
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
