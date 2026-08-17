# Preview at http://localhost:3000/rails/mailers/listing_mailer/price_dropped
class ListingMailerPreview < ActionMailer::Preview
  def price_dropped
    ListingMailer.price_dropped(User.first, Listing.first)
  end
end
