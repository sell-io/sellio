# MVP: Stripe payment links. No custom checkout, no webhooks.
# Success is assumed when user reaches /payment-success.
class PaymentsController < ApplicationController
  STRIPE_BOOST_LINK = "https://buy.stripe.com/28E7sMckG6HPe9Bey608g01".freeze
  STRIPE_VERIFIED_LINK = "https://buy.stripe.com/9B66oIfwSgip6H9ahQ08g02".freeze

  before_action :authenticate_user!, only: [:redirect_boost, :redirect_verified]

  # User clicked "Boost listing" -> store listing_id in session, redirect to Stripe
  def redirect_boost
    listing = current_user.listings.find_by(id: params[:listing_id])
    unless listing
      redirect_back fallback_location: listings_path, alert: "Listing not found."
      return
    end
    session[:pending_boost_listing_id] = listing.id
    redirect_to STRIPE_BOOST_LINK, allow_other_host: true
  end

  # User clicked "Verified Seller" -> redirect to Stripe
  def redirect_verified
    redirect_to STRIPE_VERIFIED_LINK, allow_other_host: true
  end

  # Stripe redirects here after payment. Set success URL in Stripe Dashboard (Payment links → customize):
  # - Boost: https://dealo.ie/payment-success?type=boost
  # - Verified: https://dealo.ie/payment-success?type=verified
  # See STRIPE_SETUP.md. Optional: add &listingId=123 for boost (else we use session).
  def success
    type = params[:type].to_s.downcase
    listing_id = params[:listingId].presence || params[:listing_id].presence || session[:pending_boost_listing_id]

    if type == "boost"
      apply_boost(listing_id)
    elsif type == "verified"
      apply_verified
    else
      redirect_to root_path, notice: "Payment received."
      return
    end

    session.delete(:pending_boost_listing_id)
    render :success, status: :ok
  end

  private

  def apply_boost(listing_id)
    if listing_id.blank?
      @success_type = nil
      @message = "We couldn't identify which listing to boost. Please contact support if you were charged."
      return
    end
    listing = Listing.find_by(id: listing_id)
    unless listing
      @success_type = nil
      @message = "Listing not found."
      return
    end
    # Only allow boosting own listing (or admin could be added)
    unless listing.user_id == current_user&.id || current_user&.admin?
      @success_type = nil
      @message = "You can only boost your own listing."
      return
    end
    listing.update!(boosted_until: 7.days.from_now)
    @success_type = "boost"
    @listing = listing
    @message = "Your listing \"#{listing.title}\" is now boosted for 7 days!"
  end

  def apply_verified
    unless user_signed_in?
      @success_type = nil
      @message = "Please sign in to complete verification."
      return
    end
    current_user.update!(is_verified: true)
    @success_type = "verified"
    @message = "You're now a Verified Seller!"
  end
end
