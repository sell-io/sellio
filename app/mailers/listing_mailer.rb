class ListingMailer < ApplicationMailer
  def price_dropped(user, listing)
    @user = user
    @listing = listing
    mail(to: user.email, subject: "Price drop: #{listing.title} is now €#{listing.price.to_i}")
  end
end
