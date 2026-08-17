class PendingPayment < ApplicationRecord
  KINDS = %w[boost verified].freeze
  EXPIRY = 1.hour

  belongs_to :user
  belongs_to :listing, optional: true

  validates :kind, inclusion: { in: KINDS }
  validates :token, presence: true, uniqueness: true

  before_validation :assign_token, on: :create
  before_validation :assign_expiry, on: :create

  scope :redeemable, -> { where(consumed_at: nil).where("expires_at > ?", Time.current) }

  # Finds and atomically consumes the most recent redeemable pending payment for
  # the given user/kind, so the same payment can't be applied twice.
  def self.consume!(user:, kind:)
    transaction do
      redeemable.where(user: user, kind: kind).order(created_at: :desc).lock.first&.tap do |payment|
        payment.update!(consumed_at: Time.current)
      end
    end
  end

  private

  def assign_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def assign_expiry
    self.expires_at ||= EXPIRY.from_now
  end
end
