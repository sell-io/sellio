class ListingsController < ApplicationController
  before_action :set_listing, only: %i[ show edit update destroy mark_as_sold mark_available ]
  before_action :authorize_listing_owner_or_admin, only: %i[ edit update destroy mark_as_sold mark_available ]

  # GET /listings or /listings.json
  def index
    @listings = Listing.all
    # Exclude sold unless include_sold=1
    @listings = @listings.available unless params[:include_sold] == "1"
    # Featured listings: always show a small randomized set on the homepage section
    @featured_listings = Listing.available.order(Arel.sql('RANDOM()')).limit(4)
    @categories = Category.by_display_order
    
    # Category filter (by ID)
    if params[:category_id].present?
      @listings = @listings.where(category_id: params[:category_id])
      @selected_category = Category.find_by(id: params[:category_id])
    end
    
    # Search: match title only (so results match what users see in listing titles)
    if params[:search].present?
      search_term = "%#{params[:search].to_s.strip}%"
      category = Category.where("name ILIKE ?", search_term).first
      if category
        # Show listings in this category OR with search term in title
        @listings = @listings.where(
          "category_id = ? OR title ILIKE ?",
          category.id, search_term
        )
        @selected_category = category
      else
        @listings = @listings.where("title ILIKE ?", search_term)
      end
    end
    
    # Location filter
    if params[:location].present?
      @listings = @listings.where("city ILIKE ?", "%#{params[:location]}%")
    end

    # Subcategory filter (applies to any category when subcategory param is present)
    if params[:subcategory].present?
      @listings = @listings.where("extra_fields->>'subcategory' = ?", params[:subcategory])
    end

    # Car-specific filters (apply if Motors category is selected OR if any car filter params are present)
    has_car_filters = params[:make].present? || params[:model].present? || params[:min_year].present? ||
                      params[:max_year].present?
    is_motors_category = params[:category_id].present? && Category.find_by(id: params[:category_id])&.name&.downcase&.include?("motor")

    if is_motors_category || has_car_filters
      motors_category_id = Category.find_by("name ILIKE ?", "%motor%")&.id
      if motors_category_id && (has_car_filters || is_motors_category)
        @listings = @listings.where(category_id: motors_category_id)
      end
      # When car filters (make/model/year) used from homepage without category, default to Cars
      if has_car_filters && !is_motors_category && params[:subcategory].blank?
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

      if params[:min_mileage].present?
        @listings = @listings.where(
          "extra_fields->>'mileage' IS NOT NULL AND extra_fields->>'mileage' != '' AND " +
          "CAST(NULLIF(TRIM(extra_fields->>'mileage'), '') AS INTEGER) >= ?",
          params[:min_mileage].to_i
        )
      end

      if params[:max_mileage].present?
        @listings = @listings.where(
          "extra_fields->>'mileage' IS NOT NULL AND extra_fields->>'mileage' != '' AND " +
          "CAST(NULLIF(TRIM(extra_fields->>'mileage'), '') AS INTEGER) <= ?",
          params[:max_mileage].to_i
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

    if params[:posted_today] == "1"
      @listings = @listings.where("listings.created_at >= ?", Time.current.beginning_of_day)
    end

    if params[:has_images] == "1"
      @listings = @listings.joins(:images_attachments).distinct
    end

    # Sort (before pagination): newest, price_asc, price_desc, distance (distance requires location)
    case params[:sort]
    when "price_asc"
      @listings = @listings.reorder(price: :asc)
    when "price_desc"
      @listings = @listings.reorder(price: :desc)
    when "newest", "distance"
      @listings = @listings.reorder(created_at: :desc)
    else
      # Default: newest (was RANDOM() before)
      @listings = @listings.reorder(created_at: :desc)
    end

    # Paginate with limit/offset (24 per page)
    per_page = 24
    @listings_total_count = @listings.count
    page_num = [params[:page].to_i, 1].max
    @listings = @listings.limit(per_page).offset((page_num - 1) * per_page)
    @listings_current_page = page_num
    @listings_per_page = per_page
    @listings_total_pages = (@listings_total_count.to_f / per_page).ceil
  end

  # GET /listings/1 or /listings/1.json
  def show
    # Reload to ensure we have the latest data, especially image order
    @listing.reload if @listing.persisted?
    # Similar listings: same category, exclude current, available only (only when listing has a category)
    @similar_listings = if @listing.category_id.present?
      Listing.available
             .where(category_id: @listing.category_id)
             .where.not(id: @listing.id)
             .order(Arel.sql("RANDOM()"))
             .limit(6)
    else
      Listing.none
    end
    Rails.logger.info "Listing #{@listing.id} - Show action. Image order: #{@listing.extra_fields&.dig('image_order').inspect}, Total attachments: #{@listing.images_attachments.count}"
  end

  # POST /listings/:id/mark_as_sold
  def mark_as_sold
    @listing.update!(status: "sold")
    redirect_to @listing, notice: "Listing marked as sold."
  end

  # POST /listings/:id/mark_available
  def mark_available
    @listing.update!(status: "available")
    redirect_to @listing, notice: "Listing marked as available again."
  end

  # GET /listings/new
  def new
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Please login to place an ad"
      return
    end
    @listing = Listing.new
    @categories = Category.visible.order(:name)
  end

  # GET /listings/1/edit
  def edit
    @categories = Category.visible.order(:name)
    # CRITICAL: Reload to ensure we have the latest images and order
    @listing.reload
    Rails.logger.info "Edit action - Listing #{@listing.id}: Total attachments: #{@listing.images_attachments.count}, Image order: #{@listing.extra_fields&.dig('image_order').inspect}"
  end

  # POST /listings or /listings.json
  def create
    @listing = Listing.new(listing_params)
    @listing.user = current_user if user_signed_in?
    @categories = Category.visible.order(:name)

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
      
      # CRITICAL: Extract images BEFORE update to prevent Rails from deleting existing images
      # Rails will DELETE all existing images if images: [] or images: nil is passed to update()
      new_images = nil
      has_new_images = false
      
      if update_params.key?(:images)
        images_param = update_params[:images]
        # Check if it's actually a file upload (not empty array or nil)
        if images_param.present?
          if images_param.is_a?(Array)
            # Filter to only actual file uploads
            real_uploads = images_param.select { |img| img.is_a?(ActionDispatch::Http::UploadedFile) }
            if real_uploads.any?
              new_images = real_uploads
              has_new_images = true
            end
          elsif images_param.is_a?(ActionDispatch::Http::UploadedFile)
            new_images = [images_param]
            has_new_images = true
          end
        end
        
        # ALWAYS remove images from update_params - we'll attach them separately
        update_params = update_params.except(:images)
        Rails.logger.info "Extracted images param from update_params to prevent deletion of existing images"
      end
      
      # Handle removed images first (before updating)
      # Rails automatically converts removed_image_ids[] into an array
      # ONLY remove images that are explicitly marked for removal
      if params[:removed_image_ids].present?
        removed_ids = params[:removed_image_ids].is_a?(Array) ? params[:removed_image_ids] : [params[:removed_image_ids]]
        removed_ids = removed_ids.reject(&:blank?).map(&:to_i)
        Rails.logger.info "Removing #{removed_ids.length} image(s) explicitly marked for removal: #{removed_ids.inspect}"
        removed_ids.each do |image_id|
          begin
            # First try by attachment ID (normal case)
            attachment = @listing.images_attachments.find_by(id: image_id)

            # Fallback: some older UI code may have sent the blob_id instead.
            # In that case, match on blob_id so the delete still works.
            if attachment.nil?
              attachment = @listing.images_attachments.find_by(blob_id: image_id)
              Rails.logger.info "Fallback matched blob_id #{image_id} to attachment #{attachment&.id}" if attachment
            end

            if attachment
              attachment.purge
              Rails.logger.info "Removed image attachment #{attachment.id} (requested id #{image_id})"
            else
              Rails.logger.warn "Image attachment with id/blob_id #{image_id} not found for removal on listing #{@listing.id}"
            end
          rescue => e
            Rails.logger.error "Error removing image #{image_id}: #{e.message}"
          end
        end
      end
      
      # Handle image order - check for combined_image_order first (new + existing)
      combined_image_order = params[:combined_image_order]
      existing_image_order = params[:existing_image_order]
      
      Rails.logger.info "Combined image order param: #{combined_image_order.inspect}"
      Rails.logger.info "Existing image order param: #{existing_image_order.inspect}"
      Rails.logger.info "Has new images: #{has_new_images}, New images count: #{new_images ? new_images.length : 0}"
      
      # Update listing WITHOUT images param to preserve existing images
      if @listing.update(update_params)
        # Attach new images separately (this appends, doesn't replace)
        if has_new_images && new_images.present?
          Rails.logger.info "Attaching #{new_images.length} new image(s) to listing #{@listing.id}"
          @listing.images.attach(new_images)
          Rails.logger.info "Attached new images. Total attachments now: #{@listing.images_attachments.count}"
        end
        # Handle image ordering - prioritize combined_image_order if present
        if combined_image_order.present?
          # Combined order contains both new and existing images in the correct order
          Rails.logger.info "Processing combined image order for listing #{@listing.id}: #{combined_image_order}"
          process_combined_image_order(@listing, combined_image_order, has_new_images)
          # CRITICAL: Ensure the save actually persisted
          @listing.reload
          Rails.logger.info "After process_combined_image_order, saved order: #{@listing.extra_fields&.dig('image_order').inspect}"
        elsif has_new_images && new_images.present?
          # New images were just attached - get them in the order they were attached
          # The most recently created attachments are the new ones
          @listing.reload  # Reload to get newly attached images
          all_attachments = @listing.images_attachments.order(created_at: :asc).to_a
          
          # The new images are at the end (most recently created)
          # But we want them at the beginning (first selected = first uploaded = should be first)
          # Count how many new images were added
          new_image_count = new_images.length
          
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
          @listing.reload
          
          Rails.logger.info "Updated image order - new images first for listing #{@listing.id}: #{image_order.inspect}"
          Rails.logger.info "Verified saved order: #{@listing.extra_fields['image_order'].inspect}"
        elsif existing_image_order.present?
          # Only existing images were reordered (no new images uploaded)
          Rails.logger.info "Reordering existing images for listing #{@listing.id} with order: #{existing_image_order}"
          reorder_existing_images(@listing, existing_image_order)
        elsif combined_image_order.blank?
          # No combined order provided - check if we need to create/update order from current state
          # This handles the case where user submits form without making changes
          if @listing.images.attached?
            # Get current order from DOM by reading the combined order input (if it exists)
            # But if it doesn't exist, create order from current attachments
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
                @listing.reload
                Rails.logger.info "Saved updated order: #{@listing.extra_fields['image_order'].inspect}"
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
                @listing.reload
                Rails.logger.info "Saved image order to database: #{@listing.extra_fields['image_order'].inspect}"
              end
            end
          end
        end
        
        # CRITICAL: Reload the listing to ensure all changes (including image order) are persisted
        @listing.reload
        
        # Verify the image order was saved correctly
        saved_order = @listing.extra_fields&.dig('image_order')
        Rails.logger.info "Listing #{@listing.id} - After update, saved image_order: #{saved_order.inspect}"
        Rails.logger.info "Listing #{@listing.id} - Total attachments: #{@listing.images_attachments.count}"
        
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
    def set_listing
      @listing = Listing.find(params.expect(:id))
    end

    def authorize_listing_owner_or_admin
      return if current_user&.admin?
      return if user_signed_in? && @listing.user_id == current_user.id

      flash[:alert] = "You are not authorized to do that."
      redirect_to @listing
    end

    # Only allow a list of trusted parameters through.
    def listing_params
      base_params = params.require(:listing).permit(
        :title, :description, :price, :city, :category_id,
        :make, :model, :year, :mileage, :engine_size,
        :fuel_type, :transmission, :previous_owners, :subcategory,
        :vehicle_registration, :performance, :dimensions, :features, :running_costs,
        images: []  # CRITICAL: Must be permitted for both create and update
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
      
      # Add any missing attachments to the end
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
      listing.save(validate: false)
      
      # Force persistence
      listing.reload
      
      Rails.logger.info "Saved image order to extra_fields: #{listing.extra_fields['image_order'].inspect}"
    end
    
    # Process combined image order (new + existing images)
    # Format: "existing:123,new:img_1,existing:456,new:img_2"
    def process_combined_image_order(listing, combined_order_string, has_new_images)
      return unless listing.images.attached? && combined_order_string.present?
      
      Rails.logger.info "Processing combined image order: #{combined_order_string}"
      
      # Parse the combined order string
      order_parts = combined_order_string.split(',').map(&:strip).reject(&:blank?)
      
      # Get all current attachments
      all_attachments = listing.images_attachments.order(created_at: :asc).to_a
      attachment_ids = all_attachments.map(&:id)
      
      # Count how many new images are in the order
      new_file_ids = order_parts.select { |part| part.start_with?('new:') }.map { |part| part.sub('new:', '') }
      
      # If new images were uploaded, they're the most recently created attachments
      # Match them to file IDs based on their position in the order string
      new_file_id_to_attachment = {}
      if has_new_images && new_file_ids.any?
        # Get the newly created attachments (last N by created_at)
        new_attachments = all_attachments.last(new_file_ids.length)
        
        # Match new attachments to file IDs based on the order they appear in the combined_order_string
        # The order in the string determines which file ID maps to which attachment
        new_file_ids.each_with_index do |file_id, order_index|
          # Find the position of this file_id in the order_parts array
          file_position_in_order = order_parts.index("new:#{file_id}")
          
          # Count how many "new:" items come before this one in the order
          new_items_before = order_parts[0...file_position_in_order].count { |p| p.start_with?('new:') }
          
          # The attachment at this position in the new_attachments array
          if new_attachments[new_items_before]
            new_file_id_to_attachment[file_id] = new_attachments[new_items_before].id
            Rails.logger.info "Mapped new file ID #{file_id} to attachment ID #{new_attachments[new_items_before].id}"
          end
        end
      end
      
      # Build final order by processing each part
      final_order = []
      order_parts.each do |part|
        if part.start_with?('existing:')
          # Existing image - extract ID
          image_id = part.sub('existing:', '').to_i
          if attachment_ids.include?(image_id)
            final_order << image_id
          else
            Rails.logger.warn "Existing image ID #{image_id} not found in attachments"
          end
        elsif part.start_with?('new:')
          # New image - map fileId to attachment ID
          file_id = part.sub('new:', '')
          attachment_id = new_file_id_to_attachment[file_id]
          if attachment_id && attachment_ids.include?(attachment_id)
            final_order << attachment_id
          else
            Rails.logger.warn "New file ID #{file_id} could not be mapped to attachment ID"
          end
        else
          # Try to parse as direct ID (fallback)
          image_id = part.to_i
          if attachment_ids.include?(image_id)
            final_order << image_id
          end
        end
      end
      
      # CRITICAL: Add any attachments not in the order (this ensures ALL images are included)
      ordered_ids = final_order.map(&:to_i)
      remaining_ids = attachment_ids - ordered_ids
      if remaining_ids.any?
        Rails.logger.warn "Found #{remaining_ids.length} attachments not in order, appending: #{remaining_ids.inspect}"
        final_order.concat(remaining_ids)
      end
      
      # Verify we have all attachments
      if final_order.length != attachment_ids.length
        Rails.logger.error "ERROR: Final order length (#{final_order.length}) doesn't match attachment count (#{attachment_ids.length})"
        # Force include all attachments
        final_order = attachment_ids.dup
        Rails.logger.warn "Forcing final_order to include all attachments: #{final_order.inspect}"
      end
      
      Rails.logger.info "Final combined image order for listing #{listing.id}: #{final_order.inspect} (should have #{attachment_ids.length} items)"
      
      # Save the order
      if listing.extra_fields.nil?
        listing.extra_fields = {}
      end
      listing.extra_fields['image_order'] = final_order
      
      # CRITICAL: Use update_column to directly update the database
      # This ensures the save happens immediately and persists
      listing.save(validate: false)
      
      # Force a database commit by reloading
      listing.reload
      
      # Verify the save worked
      verified_order = listing.extra_fields&.dig('image_order')
      Rails.logger.info "Saved combined image order: #{verified_order.inspect}"
      Rails.logger.info "Total images attached: #{listing.images_attachments.count}"
      
      # If the order didn't save, try one more time with update_column
      if verified_order != final_order
        Rails.logger.warn "Order didn't save correctly, retrying with update_column..."
        listing.update_column(:extra_fields, listing.extra_fields.merge('image_order' => final_order))
        listing.reload
        verified_order = listing.extra_fields&.dig('image_order')
        Rails.logger.info "After retry, saved order: #{verified_order.inspect}"
      end
      
      Rails.logger.info "✓ Image order saved for listing #{listing.id}: #{verified_order.inspect}"
    end
end
