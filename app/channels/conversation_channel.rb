class ConversationChannel < ApplicationCable::Channel
  def self.stream_name_for(listing_id, user_id_a, user_id_b)
    ids = [user_id_a.to_i, user_id_b.to_i].sort
    "conversation_#{listing_id}_#{ids.join('_')}"
  end

  def subscribed
    listing_id = params[:listing_id]
    other_user_id = params[:other_user_id]

    if listing_id.blank? || other_user_id.blank? || !authorized_participant?(listing_id, other_user_id)
      reject
      return
    end

    stream_from self.class.stream_name_for(listing_id, current_user.id, other_user_id)
  end

  private

  def authorized_participant?(listing_id, other_user_id)
    Message.where(listing_id: listing_id)
           .where(
             "(sender_id = :me AND recipient_id = :other) OR (sender_id = :other AND recipient_id = :me)",
             me: current_user.id, other: other_user_id
           )
           .exists?
  end
end
