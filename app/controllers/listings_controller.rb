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
    
    # Car-specific filters (only apply if Motors category is selected or car filters are used)
    if params[:category_id].present? && Category.find_by(id: params[:category_id])&.name&.downcase == "motors" || 
       params[:make].present? || params[:model].present? || params[:min_year].present? || 
       params[:max_year].present? || params[:min_price].present? || params[:max_price].present?
      
      # Ensure we are only filtering within the Motors category if specific car filters are applied
      motors_category_id = Category.find_by("name ILIKE ?", "%motor%")&.id
      @listings = @listings.where(category_id: motors_category_id) if motors_category_id && (params[:make].present? || params[:model].present? || params[:min_year].present? || params[:max_year].present?)

      if params[:make].present?
        @listings = @listings.where("extra_fields->>'make' ILIKE ?", "%#{params[:make]}%")
      end
      
      if params[:model].present?
        @listings = @listings.where("extra_fields->>'model' ILIKE ?", "%#{params[:model]}%")
      end
      
      if params[:min_year].present?
        @listings = @listings.where("CAST(extra_fields->>'year' AS INTEGER) >= ?", params[:min_year].to_i)
      end
      
      if params[:max_year].present?
        @listings = @listings.where("CAST(extra_fields->>'year' AS INTEGER) <= ?", params[:max_year].to_i)
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
      if @listing.update(listing_params)
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
end
