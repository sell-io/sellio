class Report < ApplicationRecord
  belongs_to :listing
  belongs_to :user

  validates :reason, presence: true
  validates :status, inclusion: { in: %w[open resolved] }

  scope :open, -> { where(status: "open") }
  scope :resolved, -> { where(status: "resolved") }

  REASONS = [
    "Spam or scam",
    "Inappropriate content",
    "Prohibited item",
    "Misleading or wrong category",
    "Duplicate listing",
    "Other"
  ].freeze
end
