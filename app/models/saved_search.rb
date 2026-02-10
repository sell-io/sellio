class SavedSearch < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :query_params, presence: true

  # Count listings matching this saved search that were created since the given time (e.g. last 7 days).
  # Used for account-specific "new listings" notifications.
  def new_listings_count(since: 7.days.ago)
    Listing.scoped_by_query_params(query_params).where("listings.created_at > ?", since).count
  end
end
