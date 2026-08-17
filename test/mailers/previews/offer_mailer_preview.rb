# Preview at http://localhost:3000/rails/mailers/offer_mailer
class OfferMailerPreview < ActionMailer::Preview
  def new_offer
    OfferMailer.new_offer(Offer.first || sample_offer)
  end

  def counter_offer
    OfferMailer.counter_offer(Offer.first || sample_offer)
  end

  def offer_decided
    OfferMailer.offer_decided(Offer.first || sample_offer)
  end

  private

  def sample_offer
    listing = Listing.first
    Offer.new(listing: listing, buyer: User.first, seller: listing.user, amount: 100, proposed_by: "buyer")
  end
end
