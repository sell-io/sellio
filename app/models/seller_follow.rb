class SellerFollow < ApplicationRecord
  belongs_to :user
  belongs_to :seller, class_name: "User"

  validates :user_id, uniqueness: { scope: :seller_id }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    errors.add(:seller, "can't be yourself") if user_id == seller_id
  end
end
