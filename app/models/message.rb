class Message < ApplicationRecord
  belongs_to :listing
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"

  validates :content, presence: true
  validates :listing_id, presence: true
  validates :sender_id, presence: true
  validates :recipient_id, presence: true

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
end
