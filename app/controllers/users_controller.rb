class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  # GET /users/1
  def show
    @listings = @user.listings.order(created_at: :desc)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
