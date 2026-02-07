class Category < ApplicationRecord
  HIDDEN_NAMES = %w[Fashion Hobbies].freeze

  has_many :listings, dependent: :destroy
  validates :name, presence: true, uniqueness: true

  scope :visible, -> { where.not(name: HIDDEN_NAMES) }
end
