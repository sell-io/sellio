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
  
  # Profile picture
  has_one_attached :avatar
  
  # Helper method to get unread messages count
  def unread_messages_count
    received_messages.where(read: false).count
  end
end
