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

  after_create_commit :broadcast_to_conversation
  after_create_commit :push_notify_recipient

  private

  def broadcast_to_conversation
    stream = ConversationChannel.stream_name_for(listing_id, sender_id, recipient_id)
    ActionCable.server.broadcast(stream, {
      id: id,
      sender_id: sender_id,
      content: content,
      created_at: created_at.strftime("%H:%M")
    })
  end

  def push_notify_recipient
    PushNotificationJob.perform_later(
      recipient_id,
      title: "New message from #{sender.name || sender.email}",
      body: content.to_s.truncate(120),
      path: Rails.application.routes.url_helpers.my_messages_path(message_id: id)
    )
  end
end
