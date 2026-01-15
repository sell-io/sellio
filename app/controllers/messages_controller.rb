class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: [:show]

  # GET /messages
  def index
    @messages = Message.where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
                       .order(created_at: :desc)
  end

  # GET /my_messages
  def my_messages
    # Get all messages where user is involved (sent or received)
    all_messages = Message.where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
                          .includes(:sender, :recipient, :listing)
                          .order(created_at: :asc)
    
    # Group messages by listing and other user (conversation)
    @conversations = {}
    
    all_messages.each do |message|
      # Determine the other user in the conversation
      other_user = message.sender == current_user ? message.recipient : message.sender
      conversation_key = "#{message.listing_id}_#{other_user.id}"
      
      # Initialize conversation if it doesn't exist
      unless @conversations[conversation_key]
        @conversations[conversation_key] = {
          listing: message.listing,
          other_user: other_user,
          messages: [],
          unread_count: 0,
          last_message_at: message.created_at,
          last_message: message
        }
      end
      
      # Add message to conversation
      @conversations[conversation_key][:messages] << message
      
      # Count unread messages (only if current user is recipient)
      if message.recipient == current_user && !message.read?
        @conversations[conversation_key][:unread_count] += 1
      end
      
      # Update last message time and message
      if message.created_at > @conversations[conversation_key][:last_message_at]
        @conversations[conversation_key][:last_message_at] = message.created_at
        @conversations[conversation_key][:last_message] = message
      end
    end
    
    # Sort conversations by last message time (most recent first)
    @conversations = @conversations.sort_by { |_key, conv| conv[:last_message_at] }.reverse.to_h
    
    # Load selected conversation if message_id is provided
    if params[:message_id].present?
      @selected_message = Message.find_by(id: params[:message_id])
      if @selected_message && (@selected_message.sender == current_user || @selected_message.recipient == current_user)
        @other_user = @selected_message.sender == current_user ? @selected_message.recipient : @selected_message.sender
        @conversation_messages = Message.where(listing_id: @selected_message.listing_id)
                                        .where("(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)", 
                                               current_user.id, @other_user.id, @other_user.id, current_user.id)
                                        .includes(:sender, :recipient)
                                        .order(created_at: :asc)
        # Mark as read
        @conversation_messages.where(recipient_id: current_user.id, read: false).update_all(read: true)
      end
    end
  end

  # GET /messages/1
  def show
    # Mark as read if current user is the recipient
    if @message.recipient == current_user && !@message.read?
      @message.update(read: true)
    end
  end

  # GET /messages/new
  def new
    @message = Message.new
    @listing = Listing.find(params[:listing_id]) if params[:listing_id]
    @message.recipient_id = params[:recipient_id] if params[:recipient_id]
    @message.listing_id = @listing.id if @listing
  end

  # POST /messages
  def create
    @message = Message.new(message_params)
    @message.sender = current_user

    respond_to do |format|
      if @message.save
        # Redirect to my_messages with the conversation selected
        format.html { redirect_to my_messages_path(message_id: @message.id), notice: "Message sent successfully." }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delete_conversation
  def delete_conversation
    listing_id = params[:listing_id]
    other_user_id = params[:other_user_id]

    # Delete all messages in this conversation
    Message.where(listing_id: listing_id)
           .where("(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)",
                  current_user.id, other_user_id, other_user_id, current_user.id)
           .destroy_all

    redirect_to my_messages_path, notice: "Conversation deleted successfully."
  end

  private

  def set_message
    @message = Message.find(params[:id])
    # Ensure user can only see their own messages
    unless @message.sender == current_user || @message.recipient == current_user
      redirect_to my_messages_path, alert: "You don't have permission to view this message."
    end
  end

  def message_params
    params.require(:message).permit(:listing_id, :recipient_id, :content)
  end
end
