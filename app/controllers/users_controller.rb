class UsersController < ApplicationController
  before_action :set_user, only: [:show, :follow, :unfollow]
  before_action :authenticate_user!, only: [:follow, :unfollow]

  # GET /users/1
  def show
    @listings = @user.listings.order(created_at: :desc)
    @reviews = @user.reviews_received.includes(:reviewer).order(created_at: :desc)
    @user_review = current_user&.reviews_given&.find_by(reviewed_user: @user) if user_signed_in?
    @review = Review.new
  end

  # POST /users/1/follow
  def follow
    if @user == current_user
      redirect_to @user, alert: "You can't follow yourself.", status: :see_other
      return
    end
    current_user.seller_follows.find_or_create_by!(seller: @user)
    redirect_to @user, notice: "You'll be notified when #{@user.name || @user.email} posts a new listing.", status: :see_other
  end

  # DELETE /users/1/unfollow
  def unfollow
    current_user.seller_follows.where(seller: @user).destroy_all
    redirect_to @user, notice: "Unfollowed #{@user.name || @user.email}.", status: :see_other
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
