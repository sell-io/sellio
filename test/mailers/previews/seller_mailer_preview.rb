# Preview at http://localhost:3000/rails/mailers/seller_mailer/new_listing
class SellerMailerPreview < ActionMailer::Preview
  def new_listing
    SellerMailer.new_listing(User.first, Listing.first)
  end
end
