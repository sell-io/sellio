class Offer < ApplicationRecord
  STATUSES = %w[pending accepted rejected countered withdrawn].freeze
  PROPOSERS = %w[buyer seller].freeze

  belongs_to :listing
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"
  belongs_to :previous_offer, class_name: "Offer", optional: true
  has_one :counter_offer, class_name: "Offer", foreign_key: :previous_offer_id

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates :proposed_by, inclusion: { in: PROPOSERS }
  validate :buyer_is_not_seller

  scope :pending, -> { where(status: "pending") }

  after_create_commit :notify_seller_of_offer, if: -> { previous_offer_id.blank? }
  after_create_commit :notify_responder_of_counter, if: -> { previous_offer_id.present? }
  after_update_commit :notify_proposer_of_decision, if: -> { saved_change_to_status? && %w[accepted rejected].include?(status) }

  def pending?
    status == "pending"
  end

  # The user who made the currently-pending proposal (the other party is the one who can
  # accept/reject/counter it).
  def proposer
    proposed_by == "buyer" ? buyer : seller
  end

  # The user who needs to respond to the currently-pending proposal.
  def responder
    proposed_by == "buyer" ? seller : buyer
  end

  def accept!
    update!(status: "accepted")
  end

  def reject!
    update!(status: "rejected")
  end

  # Only the proposer can withdraw their own still-open offer.
  def withdraw!
    update!(status: "withdrawn")
  end

  # The responder proposes a different amount: closes this offer and opens a new linked one
  # that the original proposer now needs to respond to.
  def counter!(amount:, message: nil)
    transaction do
      update!(status: "countered")
      Offer.create!(
        listing: listing, buyer: buyer, seller: seller,
        amount: amount, message: message, previous_offer: self,
        proposed_by: proposed_by == "buyer" ? "seller" : "buyer"
      )
    end
  end

  private

  def buyer_is_not_seller
    errors.add(:buyer, "can't be the seller") if buyer_id == seller_id
  end

  def notify_seller_of_offer
    OfferMailer.new_offer(self).deliver_later
    PushNotifier.notify(
      seller,
      title: "New offer on #{listing.title}",
      body: "€#{amount.to_i} offered",
      path: Rails.application.routes.url_helpers.offers_path
    )
  end

  def notify_responder_of_counter
    OfferMailer.counter_offer(self).deliver_later
    PushNotifier.notify(
      responder,
      title: "Counter-offer on #{listing.title}",
      body: "€#{amount.to_i} proposed",
      path: Rails.application.routes.url_helpers.offers_path
    )
  end

  def notify_proposer_of_decision
    OfferMailer.offer_decided(self).deliver_later
    PushNotifier.notify(
      proposer,
      title: "Your offer was #{status}",
      body: "#{listing.title} - €#{amount.to_i}",
      path: Rails.application.routes.url_helpers.offers_path
    )
  end
end
