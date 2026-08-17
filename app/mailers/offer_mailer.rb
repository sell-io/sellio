class OfferMailer < ApplicationMailer
  def new_offer(offer)
    @offer = offer
    mail(to: offer.seller.email, subject: "New offer: €#{offer.amount.to_i} for #{offer.listing.title}")
  end

  def counter_offer(offer)
    @offer = offer
    mail(to: offer.responder.email, subject: "Counter-offer: €#{offer.amount.to_i} for #{offer.listing.title}")
  end

  def offer_decided(offer)
    @offer = offer
    verb = offer.status == "accepted" ? "accepted" : "rejected"
    mail(to: offer.proposer.email, subject: "Your offer was #{verb} - #{offer.listing.title}")
  end
end
