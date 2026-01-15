class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reviewed_user, only: [:create]
  
  # POST /reviews
  def create
    @review = Review.new(review_params)
    @review.reviewer = current_user
    @review.reviewed_user = @reviewed_user
    
    if @review.save
      redirect_to user_path(@reviewed_user), notice: "Review submitted successfully."
    else
      redirect_to user_path(@reviewed_user), alert: @review.errors.full_messages.join(", ")
    end
  end
  
  private
  
  def set_reviewed_user
    @reviewed_user = User.find(params[:user_id])
  end
  
  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
