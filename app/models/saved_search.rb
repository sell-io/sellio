class SavedSearch < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :query_params, presence: true

  # Count listings matching this saved search that were created since the given time (e.g. last 7 days).
  # Used for account-specific "new listings" notifications.
  def new_listings_count(since: 7.days.ago)
    matching_listings(since: since).count
  end

  # Listings matching this saved search created since the given time - used both by the count
  # above and by the digest email (SavedSearchMailer) to list the actual new listings.
  def matching_listings(since: 7.days.ago)
    Listing.scoped_by_query_params(query_params).where("listings.created_at > ?", since).order(created_at: :desc)
  end
end
