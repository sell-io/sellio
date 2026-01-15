class Review < ApplicationRecord
  belongs_to :reviewer, class_name: 'User'
  belongs_to :reviewed_user, class_name: 'User'
  
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 1000 }
  validates :reviewer_id, uniqueness: { scope: :reviewed_user_id, message: "You have already reviewed this user" }
  validate :cannot_review_self
  
  private
  
  def cannot_review_self
    if reviewer_id == reviewed_user_id
      errors.add(:reviewed_user, "You cannot review yourself")
    end
  end
end
