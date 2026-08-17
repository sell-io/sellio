# MVP: Stripe payment links. No custom checkout, no webhooks.
#
# A PendingPayment is created (server-side) right before redirecting the user to Stripe, and
# consumed (single-use, expires after PendingPayment::EXPIRY) when they land back on
# /payment-success. This means /payment-success can no longer just be visited directly, or
# replayed, to grant a boost/verification for free.
#
# This is NOT real payment verification - it doesn't confirm with Stripe that money actually
# changed hands (that needs the Stripe secret key + webhook signature checks). It only closes
# the "guess the URL, never interact with Stripe at all" hole.
class PaymentsController < ApplicationController
  STRIPE_BOOST_LINK = "https://buy.stripe.com/28E7sMckG6HPe9Bey608g01".freeze
  STRIPE_VERIFIED_LINK = "https://buy.stripe.com/9B66oIfwSgip6H9ahQ08g02".freeze

  before_action :authenticate_user!, only: [:redirect_boost, :redirect_verified, :success]

  # User clicked "Boost listing" -> use free boost if verified and available, else redirect to Stripe
  def redirect_boost
    listing = current_user.listings.find_by(id: params[:listing_id])
    unless listing
      redirect_back fallback_location: listings_path, alert: "Listing not found."
      return
    end
    if current_user.is_verified? && current_user.free_boosts_left_this_month?
      current_user.use_free_boost!
      apply_boost(listing)
      remaining = current_user.free_boosts_remaining
      @message = "Your listing \"#{listing.title}\" is now boosted for 7 days! (#{remaining} free boost#{remaining == 1 ? '' : 's'} left this month.)"
      render :success, status: :ok
      return
    end
    current_user.pending_payments.create!(kind: "boost", listing: listing)
    redirect_to STRIPE_BOOST_LINK, allow_other_host: true
  end

  # User clicked "Verified Seller" -> redirect to Stripe
  def redirect_verified
    current_user.pending_payments.create!(kind: "verified")
    redirect_to STRIPE_VERIFIED_LINK, allow_other_host: true
  end

  # Stripe redirects here after payment. Set success URL in Stripe Dashboard (Payment links → customize):
  # - Boost: https://dealo.ie/payment-success?type=boost
  # - Verified: https://dealo.ie/payment-success?type=verified
  # See STRIPE_SETUP.md.
  def success
    type = params[:type].to_s.downcase

    unless PendingPayment::KINDS.include?(type)
      redirect_to root_path, notice: "Payment received."
      return
    end

    pending_payment = PendingPayment.consume!(user: current_user, kind: type)
    unless pending_payment
      @success_type = nil
      @message = "We couldn't verify this payment. If you were charged, please contact support."
      render :success, status: :ok
      return
    end

    if type == "boost"
      apply_boost(pending_payment.listing)
    else
      apply_verified
    end

    render :success, status: :ok
  end

  private

  def apply_boost(listing)
    unless listing
      @success_type = nil
      @message = "We couldn't identify which listing to boost. Please contact support if you were charged."
      return
    end
    unless listing.user_id == current_user.id || current_user.admin?
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
    current_user.update!(is_verified: true)
    @success_type = "verified"
    @message = "You're now a Verified Seller!"
  end
end
