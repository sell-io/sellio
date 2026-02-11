class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Add your associations here
  has_many :listings, dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id'
  has_many :favorites, dependent: :destroy
  has_many :favorite_listings, through: :favorites, source: :listing
  
  # Reviews
  has_many :reviews_given, class_name: 'Review', foreign_key: 'reviewer_id', dependent: :destroy
  has_many :reviews_received, class_name: 'Review', foreign_key: 'reviewed_user_id', dependent: :destroy
  
  # Profile picture
  has_one_attached :avatar

  has_many :reports, dependent: :destroy
  has_many :saved_searches, dependent: :destroy
  
  # Helper method to get unread messages count
  def unread_messages_count
    received_messages.where(read: false).count
  end
  
  # Calculate average rating
  def average_rating
    reviews_received.average(:rating)&.round(1) || 0.0
  end
  
  # Get total number of reviews
  def reviews_count
    reviews_received.count
  end

  def banned?
    banned_at.present?
  end

  def ban!
    update!(banned_at: Time.current)
  end

  def unban!
    update!(banned_at: nil)
  end

  # Verified sellers get 3 free ad boosts per month. Resets at start of each calendar month.
  FREE_BOOSTS_PER_MONTH = 3

  def reset_free_boosts_if_new_month!
    return unless free_boosts_reset_at.nil? || free_boosts_reset_at < Time.current
    update_columns(free_boosts_reset_at: 1.month.from_now.beginning_of_month, free_boosts_used: 0)
  end

  def free_boosts_left_this_month?
    return false unless is_verified?
    reset_free_boosts_if_new_month!
    free_boosts_used < FREE_BOOSTS_PER_MONTH
  end

  def free_boosts_remaining
    return 0 unless is_verified?
    reset_free_boosts_if_new_month!
    [FREE_BOOSTS_PER_MONTH - free_boosts_used, 0].max
  end

  # When the free-boost allowance resets (start of next month). Only meaningful if is_verified? and after free_boosts_remaining has been called.
  def free_boosts_reset_on
    return nil unless is_verified?
    reset_free_boosts_if_new_month!
    free_boosts_reset_at&.strftime("%e %B")
  end

  def use_free_boost!
    increment!(:free_boosts_used)
  end
end
