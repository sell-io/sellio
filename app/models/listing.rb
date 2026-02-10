class Listing < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :user, optional: true
  has_many_attached :images
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user
  has_many :reports, dependent: :destroy

  scope :available, -> { where(status: [nil, "", "available"]) }
  scope :sold, -> { where(status: "sold") }

  before_save :track_price_drop, if: :price_changed?

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Helper methods for car-specific fields
  def license_plate
    extra_fields&.dig('license_plate')
  end
  
  def mileage
    extra_fields&.dig('mileage')
  end
  
  def engine_size
    extra_fields&.dig('engine_size')
  end
  
  def previous_owners
    extra_fields&.dig('previous_owners')
  end
  
  def year
    extra_fields&.dig('year')
  end
  
  def make
    extra_fields&.dig('make')
  end
  
  def model
    extra_fields&.dig('model')
  end
  
  def fuel_type
    extra_fields&.dig('fuel_type')
  end
  
  def transmission
    extra_fields&.dig('transmission')
  end

  def sold?
    status.to_s.downcase == "sold"
  end

  # True only when the seller has lowered the price (previous_price stored on update).
  def price_dropped?
    return false unless previous_price.present? && price.present?
    price.to_d < previous_price.to_d
  end

  def track_price_drop
    return if new_record?
    old_price = price_was
    return unless old_price.present?
    if price.to_d < old_price.to_d
      self.previous_price = old_price
    else
      self.previous_price = nil
    end
  end

  # Smart Price Checker: compare to similar listings. Returns { label:, comparison:, similar_count: } or nil.
  def price_insight
    return nil unless price.present? && price.to_d > 0
    similar = similar_listings_for_price_check
    prices = similar.pluck(:price).compact.map { |p| p.to_d }.select { |p| p > 0 }
    return nil if prices.size < 3
    median = prices.sort[prices.size / 2]
    ratio = price.to_d / median
    label = if ratio <= 0.85
      "Great Deal"
    elsif ratio >= 1.15
      "High"
    else
      "Fair"
    end
    pct = ((1 - price.to_d / median) * 100).round
    comparison = if ratio <= 0.85
      "#{pct.abs}% below typical"
    elsif ratio >= 1.15
      "#{((ratio - 1) * 100).round}% above typical"
    else
      "in line with similar ads"
    end
    { label: label, comparison: comparison, similar_count: similar.count }
  end

  def similar_listings_for_price_check
    base = Listing.available.where(category_id: category_id).where.not(id: id)
    base = base.where("city ILIKE ?", city) if city.present? && base.where("city ILIKE ?", city).count >= 3
    if category&.name&.downcase&.include?("motor") && make.present?
      by_make = base.where("extra_fields->>'make' ILIKE ?", make.to_s)
      base = by_make if by_make.count >= 3
    end
    base
  end

  # Get images in the correct order (as stored in extra_fields or by created_at)
  def ordered_images
    return [] unless images.attached?
    
    # Check if we have a stored order
    stored_order = extra_fields&.dig('image_order')
    
    Rails.logger.info "Listing #{id} - ordered_images called. Stored order: #{stored_order.inspect}, Total attachments: #{images_attachments.count}, extra_fields keys: #{extra_fields&.keys.inspect}"
    
    if stored_order.present? && stored_order.is_a?(Array) && stored_order.any?
      # Reorder based on stored order
      attachments_by_id = images_attachments.index_by(&:id)
      ordered_attachments = stored_order.map do |id|
        attachments_by_id[id.to_i]
      end.compact
      
      Rails.logger.info "Listing #{id} - Found #{ordered_attachments.count} attachments from stored order (expected #{stored_order.length})"
      
      # CRITICAL: Add any attachments not in the stored order (this handles cases where new images were added but order wasn't updated)
      existing_ids = stored_order.map(&:to_i)
      remaining_attachments = images_attachments.reject { |a| existing_ids.include?(a.id) }
      if remaining_attachments.any?
        Rails.logger.warn "Listing #{id} - WARNING: Found #{remaining_attachments.count} attachments not in stored order, appending them"
        ordered_attachments.concat(remaining_attachments)
      end
      
      # Return the blobs in order - ensure we return an array
      result = ordered_attachments.map(&:blob).compact
      Rails.logger.info "Listing #{id} - ordered_images from stored order: #{result.count} images (expected #{images_attachments.count})"
      
      # CRITICAL: If we're missing images, fall back to showing all images in created_at order
      if result.count != images_attachments.count
        Rails.logger.error "Listing #{id} - ERROR: ordered_images count (#{result.count}) doesn't match attachments count (#{images_attachments.count}). Falling back to created_at order."
        # Return all images in created_at order as fallback
        result = images_attachments.order(created_at: :asc).map(&:blob).compact
        Rails.logger.info "Listing #{id} - Fallback: returning #{result.count} images in created_at order"
      end
      
      result
    else
      # No stored order, use created_at order (first uploaded = first)
      result = images_attachments.order(created_at: :asc).map(&:blob).compact
      Rails.logger.info "Listing #{id} - ordered_images from created_at: #{result.count} images (no stored order found)"
      result
    end
  end
end


