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
end
