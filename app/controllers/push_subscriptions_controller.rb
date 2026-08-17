class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    subscription = current_user.push_subscriptions.find_or_initialize_by(endpoint: params[:endpoint])
    subscription.assign_attributes(p256dh: params[:p256dh], auth: params[:auth])

    if subscription.save
      head :created
    else
      render json: subscription.errors, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.push_subscriptions.find_by(endpoint: params[:endpoint])&.destroy
    head :no_content
  end
end
