class SellerMailer < ApplicationMailer
  def new_listing(follower, listing)
    @follower = follower
    @listing = listing
    @seller = listing.user
    mail(to: follower.email, subject: "#{@seller.name || @seller.email} just listed: #{listing.title}")
  end
end
