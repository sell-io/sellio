# Preview at http://localhost:3000/rails/mailers/saved_search_mailer/new_listings
class SavedSearchMailerPreview < ActionMailer::Preview
  def new_listings
    saved_search = SavedSearch.first
    SavedSearchMailer.new_listings(saved_search, saved_search.matching_listings(since: 1.year.ago))
  end
end
