class Category < ApplicationRecord
  HIDDEN_NAMES = %w[Fashion Hobbies].freeze

  # Display order for navigation and Browse by Category (demand-led)
  DISPLAY_ORDER = [
    "Motors", "Properties", "Property", "Electronics", "Furniture",
    "Baby + Kids", "Sport + Hobbies", "Services", "Animals", "Farming",
    "Music + Education"
  ].freeze

  has_many :listings, dependent: :destroy
  validates :name, presence: true, uniqueness: true

  scope :visible, -> { where.not(name: HIDDEN_NAMES) }

  # Categories in demand order for Browse / Buy dropdown
  scope :by_display_order, -> {
    order_clause = "CASE " + DISPLAY_ORDER.each_with_index.map { |name, i|
      "WHEN name ILIKE #{connection.quote(name)} THEN #{i}"
    }.join(" ") + " ELSE #{DISPLAY_ORDER.size} END"
    visible.order(Arel.sql(order_clause)).order(:name)
  }
end
