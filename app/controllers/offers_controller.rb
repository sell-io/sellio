class OffersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:new, :create]
  before_action :set_offer, only: [:accept, :reject, :counter, :withdraw]
  before_action :authorize_responder!, only: [:accept, :reject, :counter]
  before_action :authorize_proposer!, only: [:withdraw]
  before_action :require_pending!, only: [:accept, :reject, :counter, :withdraw]

  # GET /offers - "my offers", both sent (as buyer) and received (as seller). Only the current
  # (non-superseded) offer in each negotiation thread is shown - a "countered" row always has a
  # follow-up offer that replaced it.
  def index
    @offers_received = current_user.offers_received.where.not(status: "countered").includes(:listing, :buyer, :seller).order(created_at: :desc)
    @offers_made = current_user.offers_made.where.not(status: "countered").includes(:listing, :buyer, :seller).order(created_at: :desc)
  end

  # GET /listings/:listing_id/offers/new
  def new
    if @listing.user_id == current_user.id
      redirect_to @listing, alert: "You can't make an offer on your own listing.", status: :see_other
      return
    end
    @offer = Offer.new(amount: @listing.price)
  end

  # POST /listings/:listing_id/offers
  def create
    @offer = current_user.offers_made.build(offer_params)
    @offer.listing = @listing
    @offer.seller = @listing.user
    @offer.proposed_by = "buyer"

    if @offer.save
      redirect_to offers_path, notice: "Offer sent for €#{@offer.amount.to_i}.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # POST /offers/:id/accept
  def accept
    @offer.accept!
    redirect_to offers_path, notice: "Offer accepted.", status: :see_other
  end

  # POST /offers/:id/reject
  def reject
    @offer.reject!
    redirect_to offers_path, notice: "Offer rejected.", status: :see_other
  end

  # POST /offers/:id/counter
  def counter
    amount = params[:amount]
    if amount.blank? || amount.to_d <= 0
      redirect_to offers_path, alert: "Enter a valid counter-offer amount.", status: :see_other
      return
    end
    @offer.counter!(amount: amount, message: params[:message])
    redirect_to offers_path, notice: "Counter-offer sent for €#{amount.to_i}.", status: :see_other
  end

  # POST /offers/:id/withdraw
  def withdraw
    @offer.withdraw!
    redirect_to offers_path, notice: "Offer withdrawn.", status: :see_other
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def set_offer
    @offer = Offer.find(params[:id])
  end

  def authorize_responder!
    return if @offer.responder.id == current_user.id

    redirect_to offers_path, alert: "You're not authorized to do that.", status: :see_other
  end

  def authorize_proposer!
    return if @offer.proposer.id == current_user.id

    redirect_to offers_path, alert: "You're not authorized to do that.", status: :see_other
  end

  def require_pending!
    return if @offer.pending?

    redirect_to offers_path, alert: "That offer isn't pending anymore.", status: :see_other
  end

  def offer_params
    params.require(:offer).permit(:amount, :message)
  end
end
