class Listing < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :user, optional: true
  has_many_attached :images
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user
  
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
  
  # Get images in the correct order (as stored in extra_fields or by created_at)
  def ordered_images
    return images unless images.attached?
    
    # Check if we have a stored order
    stored_order = extra_fields&.dig('image_order')
    
    if stored_order.present? && stored_order.is_a?(Array)
      # Reorder based on stored order
      attachments_by_id = images_attachments.index_by(&:id)
      ordered_attachments = stored_order.map do |id|
        attachments_by_id[id.to_i]
      end.compact
      
      # Add any attachments not in the stored order (newly added)
      existing_ids = stored_order.map(&:to_i)
      remaining_attachments = images_attachments.reject { |a| existing_ids.include?(a.id) }
      ordered_attachments.concat(remaining_attachments)
      
      # Return the blobs in order
      ordered_attachments.map(&:blob)
    else
      # No stored order, use created_at order (first uploaded = first)
      images_attachments.order(created_at: :asc).map(&:blob)
    end
  end
end


