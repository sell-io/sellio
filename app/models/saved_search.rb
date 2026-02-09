class SavedSearch < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :query_params, presence: true
end
