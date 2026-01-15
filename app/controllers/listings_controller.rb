class ListingsController < ApplicationController
  before_action :set_listing, only: %i[ show edit update destroy ]

  # GET /listings or /listings.json
  def index
    @listings = Listing.all.order(created_at: :desc)
    # Order categories with Motors first, then alphabetically
    all_categories = Category.all.order(:name)
    motors_category = all_categories.find { |c| c.name.downcase == "motors" }
    @categories = if motors_category
      [motors_category] + (all_categories - [motors_category])
    else
      all_categories
    end
    
    # Category filter (by ID)
    if params[:category_id].present?
      @listings = @listings.where(category_id: params[:category_id])
      @selected_category = Category.find_by(id: params[:category_id])
    end
    
    # Search functionality (also handles category name searches from fallback categories)
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      # First try to find by category name
      category = Category.where("name ILIKE ?", search_term).first
      if category
        @listings = @listings.where(category_id: category.id)
        @selected_category = category
      else
        # Otherwise search in title and description
        @listings = @listings.where("title ILIKE ? OR description ILIKE ?", 
                                     search_term, 
                                     search_term)
      end
    end
    
    # Location filter
    if params[:location].present?
      @listings = @listings.where("city ILIKE ?", "%#{params[:location]}%")
    end
    
    # Car-specific filters (apply if Motors category is selected OR if any car filter params are present)
    has_car_filters = params[:make].present? || params[:model].present? || params[:min_year].present? || 
                      params[:max_year].present? || params[:subcategory].present?
    is_motors_category = params[:category_id].present? && Category.find_by(id: params[:category_id])&.name&.downcase&.include?("motor")
    
    if is_motors_category || has_car_filters
      # Ensure we are only filtering within the Motors category if car filters are applied
      motors_category_id = Category.find_by("name ILIKE ?", "%motor%")&.id
      if motors_category_id && (has_car_filters || is_motors_category)
        @listings = @listings.where(category_id: motors_category_id)
      end

      # Vehicle type filter (subcategory) - must be applied when car filters are used from homepage
      # If subcategory is "Car" from homepage filter, ensure it's applied
      if params[:subcategory].present?
        @listings = @listings.where("extra_fields->>'subcategory' = ?", params[:subcategory])
      elsif has_car_filters && !is_motors_category
        # If car filters are used but no subcategory specified, default to "Car" for homepage searches
        @listings = @listings.where("extra_fields->>'subcategory' = ?", "Car")
      end

      if params[:make].present?
        # Search in both make field and title (in case make isn't stored separately)
        @listings = @listings.where(
          "extra_fields->>'make' ILIKE ? OR title ILIKE ?",
          "%#{params[:make]}%",
          "%#{params[:make]}%"
        )
      end
      
      if params[:model].present?
        # Search in both model field and title (in case model isn't stored separately)
        # When both make and model are specified, ensure they appear together to prevent cross-make matches
        if params[:make].present?
          # When make is specified, the model must appear with the make
          # Match if: (model in model field AND make matches) OR (both make and model in title)
          @listings = @listings.where(
            "(extra_fields->>'model' ILIKE ? AND extra_fields->>'make' ILIKE ?) OR " +
            "(title ILIKE ? AND title ILIKE ?)",
            "%#{params[:model]}%",
            "%#{params[:make]}%",
            "%#{params[:make]}%",
            "%#{params[:model]}%"
          )
        else
          # If no make specified, search model normally
          @listings = @listings.where(
            "extra_fields->>'model' ILIKE ? OR title ILIKE ?",
            "%#{params[:model]}%",
            "%#{params[:model]}%"
          )
        end
      end
      
      if params[:min_year].present?
        # Handle year stored as string - convert to integer for comparison
        # Use COALESCE and NULLIF to handle empty strings and nulls
        @listings = @listings.where(
          "extra_fields->>'year' IS NOT NULL AND extra_fields->>'year' != '' AND " +
          "CAST(NULLIF(extra_fields->>'year', '') AS INTEGER) >= ?",
          params[:min_year].to_i
        )
      end
      
      if params[:max_year].present?
        # Handle year stored as string - convert to integer for comparison
        @listings = @listings.where(
          "extra_fields->>'year' IS NOT NULL AND extra_fields->>'year' != '' AND " +
          "CAST(NULLIF(extra_fields->>'year', '') AS INTEGER) <= ?",
          params[:max_year].to_i
        )
      end
    end
    
    # Price filters (apply to all categories)
    if params[:min_price].present?
      @listings = @listings.where("price >= ?", params[:min_price].to_i)
    end
    
    if params[:max_price].present?
      @listings = @listings.where("price <= ?", params[:max_price].to_i)
    end
  end

  # GET /listings/1 or /listings/1.json
  def show
  end

  # GET /listings/new
  def new
    @listing = Listing.new
    @categories = Category.all
  end

  # GET /listings/1/edit
  def edit
    @categories = Category.all
  end

  # POST /listings or /listings.json
  def create
    @listing = Listing.new(listing_params)
    @listing.user = current_user if user_signed_in?
    @categories = Category.all

    respond_to do |format|
      if @listing.save
        # Reorder images to preserve the upload order (first uploaded = first/main image)
        reorder_listing_images(@listing)
        format.html { redirect_to @listing, notice: "Listing was successfully created." }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1 or /listings/1.json
  def update
    respond_to do |format|
      # Get the params and handle images separately
      update_params = listing_params
      
      # Handle removed images first (before updating)
      # Rails automatically converts removed_image_ids[] into an array
      if params[:removed_image_ids].present?
        removed_ids = params[:removed_image_ids].is_a?(Array) ? params[:removed_image_ids] : [params[:removed_image_ids]]
        removed_ids.reject(&:blank?).each do |image_id|
          begin
            image = @listing.images.find_by(id: image_id.to_i)
            image&.purge
          rescue => e
            Rails.logger.error "Error removing image #{image_id}: #{e.message}"
          end
        end
      end
      
      # Check if new images are being uploaded
      new_images = update_params[:images]
      has_new_images = false
      
      if new_images.present?
        # Check if there are any actual file uploads (not just empty strings)
        if new_images.is_a?(Array)
          has_new_images = new_images.any? { |img| img.is_a?(ActionDispatch::Http::UploadedFile) }
        elsif new_images.is_a?(ActionDispatch::Http::UploadedFile)
          has_new_images = true
        end
      end
      
      # Handle image order for existing images
      existing_image_order = params[:existing_image_order]
      Rails.logger.info "Existing image order param: #{existing_image_order.inspect}"
      
      # If no new images are provided, remove images from params to preserve existing ones
      # But if all images were removed via removed_image_ids, we want to allow that
      unless has_new_images
        update_params = update_params.except(:images)
      end
      
      if @listing.update(update_params)
        # Reorder images to preserve the correct order
        # The key: new images from file input come in selection order
        # We want the FIRST selected image to be the FIRST/main image
        if has_new_images
          # New images were just attached - get them in the order they were attached
          # The most recently created attachments are the new ones
          all_attachments = @listing.images_attachments.order(created_at: :asc).to_a
          
          # The new images are at the end (most recently created)
          # But we want them at the beginning (first selected = first uploaded = should be first)
          # Count how many new images were added
          new_image_count = update_params[:images].is_a?(Array) ? update_params[:images].select { |img| img.is_a?(ActionDispatch::Http::UploadedFile) }.length : 1
          
          # Get the new attachments (last N attachments by created_at)
          new_attachments = all_attachments.last(new_image_count)
          existing_attachments = all_attachments[0..-(new_image_count + 1)] || []
          
          # Combine: new images FIRST (in the order they were selected/uploaded), then existing
          # This ensures the first selected image becomes the cover/main picture
          ordered_attachments = new_attachments + existing_attachments
          image_order = ordered_attachments.map(&:id)
          
          if @listing.extra_fields.nil?
            @listing.extra_fields = {}
          end
          @listing.extra_fields['image_order'] = image_order
          @listing.save(validate: false)
          
          Rails.logger.info "Updated image order - new images first for listing #{@listing.id}: #{image_order.inspect}"
        elsif existing_image_order.present?
          # Only existing images were reordered (no new images uploaded)
          Rails.logger.info "Reordering existing images for listing #{@listing.id} with order: #{existing_image_order}"
          reorder_existing_images(@listing, existing_image_order)
        else
          # No explicit order provided in params
          # BUT we should preserve the existing order if it exists
          # This handles the case where user submits form without making changes
          if @listing.images.attached?
            if @listing.extra_fields.nil? || @listing.extra_fields['image_order'].blank?
              # No order exists - create one from current attachments
              Rails.logger.info "No image order found, creating one from current attachments for listing #{@listing.id}"
              reorder_listing_images(@listing)
            else
              # Order exists - validate and preserve it
              # This ensures the order is maintained even if user doesn't explicitly change it
              existing_order = @listing.extra_fields['image_order']
              current_attachment_ids = @listing.images_attachments.pluck(:id)
              valid_order = existing_order.select { |id| current_attachment_ids.include?(id.to_i) }
              
              # Add any new attachments not in the order (shouldn't happen, but safety check)
              missing_ids = current_attachment_ids - valid_order.map(&:to_i)
              final_order = valid_order.map(&:to_i) + missing_ids
              
              if final_order != existing_order.map(&:to_i)
                Rails.logger.info "Updating image order to remove invalid IDs for listing #{@listing.id}"
                @listing.extra_fields['image_order'] = final_order
                @listing.save(validate: false)
              else
                # Order is valid - explicitly save it to ensure it persists
                # This is important when user submits without changes
                Rails.logger.info "Preserving existing image order for listing #{@listing.id}: #{final_order.inspect}"
                # Make sure extra_fields is initialized
                if @listing.extra_fields.nil?
                  @listing.extra_fields = {}
                end
                @listing.extra_fields['image_order'] = final_order
                @listing.save(validate: false)
                Rails.logger.info "Saved image order to database: #{@listing.extra_fields['image_order'].inspect}"
              end
            end
          end
        end
        
        format.html { redirect_to @listing, notice: "Listing was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1 or /listings/1.json
  def destroy
    @listing.destroy!

    respond_to do |format|
      format.html { redirect_to listings_path, notice: "Listing was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # GET /my_listings
  def my_listings
    @listings = Listing.where(user_id: current_user.id).order(created_at: :desc)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def listing_params
      base_params = params.require(:listing).permit(
        :title, :description, :price, :city, :category_id,
        :make, :model, :year, :mileage, :engine_size,
        :fuel_type, :transmission, :previous_owners, :subcategory,
        :vehicle_registration, :performance, :dimensions, :features, :running_costs,
        images: []
      )
      
      # Build extra_fields hash for category-specific data
      extra_fields = {}
      motors_fields = [:make, :model, :year, :mileage, :engine_size, :fuel_type, :transmission, :previous_owners, :subcategory]
      
      # Extract motors fields and remove from base_params to prevent assignment errors
      motors_fields.each do |field|
        if base_params.key?(field)
          extra_fields[field.to_s] = base_params[field] if base_params[field].present?
          base_params = base_params.except(field)
        end
      end
      
      # Store vehicle registration privately (not in public extra_fields)
      # Always remove it from base_params to prevent assignment errors
      if base_params.key?(:vehicle_registration)
        extra_fields['vehicle_registration'] = base_params[:vehicle_registration] if base_params[:vehicle_registration].present?
        base_params = base_params.except(:vehicle_registration)
      end
      
      # Store performance, dimensions, features, running_costs
      # Always remove them from base_params to prevent assignment errors
      [:performance, :dimensions, :features, :running_costs].each do |field|
        if base_params.key?(field)
          if base_params[field].present?
            begin
              parsed_data = JSON.parse(base_params[field]) if base_params[field].is_a?(String)
              extra_fields[field.to_s] = parsed_data if parsed_data
            rescue JSON::ParserError
              # Invalid JSON, skip
            end
          end
          base_params = base_params.except(field)
        end
      end
      
      base_params[:extra_fields] = extra_fields if extra_fields.any?
      base_params
    end
    
    # Reorder listing images to preserve upload/selection order
    # The first image uploaded should be the first/main image
    def reorder_listing_images(listing)
      return unless listing.images.attached?
      
      # Get all attachments ordered by created_at (upload order)
      # The most recently uploaded images come last, so we want them in upload order
      attachments = listing.images_attachments.order(created_at: :asc).to_a
      
      # Store the order in extra_fields for future reference
      # This ensures the first uploaded image stays first
      image_order = attachments.map(&:id)
      
      if listing.extra_fields.nil?
        listing.extra_fields = {}
      end
      listing.extra_fields['image_order'] = image_order
      listing.save(validate: false) # Save without validation to avoid issues
      
      Rails.logger.info "Stored image order for listing #{listing.id}: #{image_order.inspect}"
    end
    
    # Reorder existing images based on provided order
    def reorder_existing_images(listing, image_order_string)
      return unless listing.images.attached? && image_order_string.present?
      
      # Parse the order string (comma-separated image IDs)
      ordered_ids = image_order_string.split(',').map(&:strip).reject(&:blank?)
      return if ordered_ids.empty?
      
      Rails.logger.info "Parsed ordered IDs: #{ordered_ids.inspect}"
      
      # Get all current attachments
      attachments = listing.images_attachments.to_a
      Rails.logger.info "Current attachment IDs: #{attachments.map(&:id).inspect}"
      
      # Validate that all IDs in the order exist
      # Convert to integers for comparison (attachment IDs are integers)
      ordered_ids_int = ordered_ids.map(&:to_i)
      attachment_ids = attachments.map(&:id)
      
      # Filter to only include IDs that actually exist
      valid_ordered_ids = ordered_ids_int.select { |id| attachment_ids.include?(id) }
      
      # If we have any remaining attachments not in the order, append them
      remaining_ids = attachment_ids - valid_ordered_ids
      final_order = valid_ordered_ids + remaining_ids
      
      Rails.logger.info "Final image order for listing #{listing.id}: #{final_order.inspect}"
      
      # Reorder attachments based on the provided order
      # Note: Active Storage doesn't have a built-in position field, so we store order in extra_fields
      # and use it when displaying
      if listing.extra_fields.nil?
        listing.extra_fields = {}
      end
      listing.extra_fields['image_order'] = final_order
      result = listing.save(validate: false)
      
      Rails.logger.info "Saved image order to extra_fields: #{listing.extra_fields['image_order'].inspect}, save result: #{result}"
      Rails.logger.info "Listing extra_fields after save: #{listing.extra_fields.inspect}"
    end
end
