class SavedSearchMailer < ApplicationMailer
  def new_listings(saved_search, listings)
    @saved_search = saved_search
    @user = saved_search.user
    @listings = listings
    mail(to: @user.email, subject: "#{listings.count} new #{'listing'.pluralize(listings.count)} for \"#{saved_search.name}\"")
  end
end
