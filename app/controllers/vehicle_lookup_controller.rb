class VehicleLookupController < ApplicationController
  # Irish Vehicle Registration Lookup using MotorCheck public lookup
  # Uses MotorCheck's website to lookup vehicle details
  
  skip_before_action :verify_authenticity_token, only: [:lookup]
  
  def lookup
    registration = params[:registration]&.upcase&.gsub(/\s+/, '')
    
    if registration.blank?
      render json: { error: 'Registration number is required' }, status: :bad_request
      return
    end
    
    # Validate Irish registration format
    unless valid_irish_registration?(registration)
      render json: { success: false, error: 'Invalid Irish registration format. Please enter in format: YYYY-C-#####' }, status: :bad_request
      return
    end
    
    # Lookup vehicle using MotorCheck
    begin
      vehicle_data = lookup_motorcheck(registration)
      
      if vehicle_data && vehicle_data[:make].present?
        render json: { success: true, data: vehicle_data }
      else
        Rails.logger.warn "Vehicle lookup returned no data for registration: #{registration}"
        render json: { 
          success: false, 
          error: 'Vehicle not found. Please enter details manually.',
          debug: Rails.env.development? ? "Registration format: #{registration}" : nil
        }, status: :not_found
      end
    rescue => e
      Rails.logger.error "Vehicle lookup exception: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { 
        success: false, 
        error: 'Error looking up vehicle. Please enter details manually.',
        debug: Rails.env.development? ? e.message : nil
      }, status: :internal_server_error
    end
  end
  
  private
  
  def valid_irish_registration?(registration)
    # Irish registration formats - be more lenient
    # Format: YYYY-C-##### (e.g., 181-D-12345) or YYYY-C-####
    # Also accepts without dashes: YYYYC#####
    # Also accepts spaces: YYYY C #####
    normalized = registration.gsub(/[\s-]/, '')
    normalized.match?(/^\d{2,3}[A-Z]\d{1,6}$/i)
  end
  
  def lookup_motorcheck(registration)
    require 'net/http'
    require 'uri'
    require 'nokogiri'
    require 'json'
    
    # Normalize registration - MotorCheck typically uses format without dashes
    normalized_reg = registration.gsub(/[\s-]/, '').upcase
    
    Rails.logger.info "Looking up MotorCheck for registration: #{normalized_reg}"
    
    begin
      # MotorCheck free car check page
      base_uri = URI.parse("https://www.motorcheck.ie")
      
      http = Net::HTTP.new(base_uri.host, base_uri.port)
      http.use_ssl = true
      http.read_timeout = 20
      
      # Step 1: Get the free car check page
      get_request = Net::HTTP::Get.new("/free-car-check/")
      get_request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
      get_request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      get_request['Accept-Language'] = 'en-US,en;q=0.9'
      
      get_response = http.request(get_request)
      Rails.logger.info "MotorCheck GET response code: #{get_response.code}"
      
      if get_response.code != '200'
        Rails.logger.error "Failed to load MotorCheck page: #{get_response.code}"
        return nil
      end
      
      doc = Nokogiri::HTML(get_response.body)
      
      # Step 2: Find the lookup form and extract any required tokens
      form = doc.css('form').find { |f| 
        f['action'].to_s.include?('check') || 
        f['action'].to_s.include?('lookup') ||
        f.css('input[name*="reg"]').any? ||
        f.css('input[type="text"]').any?
      }
      
      if form.nil?
        Rails.logger.warn "No form found on MotorCheck page, trying direct lookup"
        # Try direct URL approach
        return lookup_motorcheck_direct(normalized_reg, http)
      end
      
      Rails.logger.info "Found form with action: #{form['action']}"
      
      # Extract form data
      form_data = {}
      
      # Get all hidden inputs
      form.css('input[type="hidden"]').each do |input|
        form_data[input['name']] = input['value'] if input['name']
      end
      
      # Find registration input field
      reg_input = form.css('input[name*="reg"], input[name*="registration"], input[type="text"]').first
      reg_field_name = if reg_input && reg_input['name']
        reg_input['name']
      else
        'reg' # Default field name
      end
      
      form_data[reg_field_name] = normalized_reg
      
      # Get form action
      form_action = form['action']
      if form_action.nil? || form_action.empty?
        form_action = '/free-car-check/'
      end
      
      # Build full URL
      action_uri = form_action.start_with?('http') ? URI.parse(form_action) : URI.join(base_uri, form_action)
      
      Rails.logger.info "Submitting form to: #{action_uri}"
      Rails.logger.info "Form data: #{form_data.inspect}"
      
      # Step 3: Submit the form
      post_request = Net::HTTP::Post.new(action_uri.path)
      post_request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
      post_request['Content-Type'] = 'application/x-www-form-urlencoded'
      post_request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      post_request['Referer'] = 'https://www.motorcheck.ie/free-car-check/'
      post_request['Origin'] = 'https://www.motorcheck.ie'
      post_request.set_form_data(form_data)
      
      response = http.request(post_request)
      Rails.logger.info "MotorCheck POST response code: #{response.code}"
      Rails.logger.info "Response location: #{response['Location']}" if response['Location']
      
      # Handle redirects
      if response.code == '302' || response.code == '301'
        redirect_location = response['Location']
        if redirect_location
          redirect_uri = redirect_location.start_with?('http') ? URI.parse(redirect_location) : URI.join(base_uri, redirect_location)
          Rails.logger.info "Following redirect to: #{redirect_uri}"
          
          redirect_request = Net::HTTP::Get.new(redirect_uri.path + (redirect_uri.query ? "?#{redirect_uri.query}" : ""))
          redirect_request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
          redirect_response = http.request(redirect_request)
          doc = Nokogiri::HTML(redirect_response.body)
        else
          doc = Nokogiri::HTML(response.body)
        end
      else
        doc = Nokogiri::HTML(response.body)
      end
      
      # Parse the response
      result = parse_motorcheck_response(doc, registration)
      
      if result && result[:make].present?
        Rails.logger.info "Successfully found vehicle: #{result[:make]} #{result[:model]}"
        return result
      else
        Rails.logger.warn "No vehicle data found in response, trying direct lookup"
        Rails.logger.debug "Response body preview: #{response.body[0..500]}" if response.body
        # Try direct lookup as fallback
        direct_result = lookup_motorcheck_direct(normalized_reg, http)
        return direct_result if direct_result && direct_result[:make].present?
        
        # Last resort: return basic data from registration
        Rails.logger.warn "MotorCheck lookup failed, returning basic data from registration"
        return basic_data_from_registration(registration)
      end
      
    rescue => e
      Rails.logger.error "MotorCheck lookup error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end
  
  def lookup_motorcheck_direct(registration, http)
    # Try direct URL lookup
    begin
      direct_uri = URI.parse("https://www.motorcheck.ie/free-car-check/?reg=#{URI.encode_www_form_component(registration)}")
      direct_request = Net::HTTP::Get.new(direct_uri.path + "?" + direct_uri.query)
      direct_request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      direct_response = http.request(direct_request)
      
      Rails.logger.info "Direct lookup response code: #{direct_response.code}"
      
      if direct_response.code == '200'
        doc = Nokogiri::HTML(direct_response.body)
        return parse_motorcheck_response(doc, registration)
      end
    rescue => e
      Rails.logger.error "Direct lookup error: #{e.message}"
    end
    
    nil
  end
  
  def lookup_motorcheck_webpage(registration)
    require 'net/http'
    require 'uri'
    require 'nokogiri'
    
    begin
      # Try accessing MotorCheck's free check page
      uri = URI.parse("https://www.motorcheck.ie/free-car-check/")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 15
      
      # Get the page first
      get_request = Net::HTTP::Get.new(uri.path)
      get_request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
      get_response = http.request(get_request)
      
      # Try to find the lookup form and submit
      doc = Nokogiri::HTML(get_response.body)
      
      # Look for form action
      form = doc.css('form').find { |f| f['action'].to_s.include?('check') || f['action'].to_s.include?('lookup') }
      
      if form
        form_action = form['action']
        form_method = form['method'] || 'POST'
        
        # Build form data
        form_data = {}
        form.css('input[type="hidden"]').each do |input|
          form_data[input['name']] = input['value'] if input['name']
        end
        
        # Add registration
        reg_input = form.css('input[name*="reg"], input[name*="registration"], input[type="text"]').first
        if reg_input && reg_input['name']
          form_data[reg_input['name']] = registration
        else
          form_data['reg'] = registration
        end
        
        # Submit form
        action_uri = form_action.start_with?('http') ? URI.parse(form_action) : URI.join(uri, form_action)
        post_request = Net::HTTP::Post.new(action_uri.path)
        post_request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        post_request['Content-Type'] = 'application/x-www-form-urlencoded'
        post_request['Referer'] = uri.to_s
        post_request.set_form_data(form_data)
        
        response = http.request(post_request)
        
        if response.code == '200' || response.code == '302'
          if response.code == '302'
            # Follow redirect
            redirect_uri = URI.parse(response['Location'])
            redirect_response = http.get(redirect_uri.path)
            doc = Nokogiri::HTML(redirect_response.body)
          else
            doc = Nokogiri::HTML(response.body)
          end
          return parse_motorcheck_response(doc, registration)
        end
      end
      
      # If form submission didn't work, try direct URL with registration
      direct_uri = URI.parse("https://www.motorcheck.ie/free-car-check/?reg=#{URI.encode_www_form_component(registration)}")
      direct_request = Net::HTTP::Get.new(direct_uri.path + "?" + direct_uri.query)
      direct_request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      direct_response = http.request(direct_request)
      
      if direct_response.code == '200'
        doc = Nokogiri::HTML(direct_response.body)
        return parse_motorcheck_response(doc, registration)
      end
      
      nil
    rescue => e
      Rails.logger.error "MotorCheck webpage lookup error: #{e.message}"
      nil
    end
  end
  
  def parse_motorcheck_json(json_data, registration)
    # Parse JSON response from MotorCheck API
    data = json_data['data'] || json_data
    
    vehicle_data = {
      make: data['make'] || data['manufacturer'],
      model: data['model'],
      year: extract_year_from_registration(registration) || data['year'],
      engine_size: data['engine_size'] || data['engine_capacity'] || data['engine'],
      fuel_type: map_fuel_type(data['fuel_type'] || data['fuel']),
      transmission: map_transmission(data['transmission'] || data['gear']),
      performance: {},
      dimensions: {},
      features: [],
      running_costs: {}
    }
    
    # Performance data
    if data['power'] || data['bhp']
      vehicle_data[:performance][:power] = "#{data['power'] || data['bhp']} bhp"
    end
    if data['torque']
      vehicle_data[:performance][:torque] = data['torque']
    end
    if data['co2'] || data['co2_emissions']
      co2 = data['co2'] || data['co2_emissions']
      vehicle_data[:performance][:co2_emissions] = "#{co2} g/km"
      vehicle_data[:running_costs][:road_tax] = calculate_road_tax_from_co2(co2.to_s)
    end
    
    # Running costs
    if data['road_tax'] || data['tax']
      vehicle_data[:running_costs][:road_tax] = data['road_tax'] || data['tax']
    end
    if data['insurance_group']
      vehicle_data[:running_costs][:insurance_group] = data['insurance_group']
    end
    
    # Clean up empty hashes
    vehicle_data[:performance] = nil if vehicle_data[:performance].empty?
    vehicle_data[:dimensions] = nil if vehicle_data[:dimensions].empty?
    vehicle_data[:features] = nil if vehicle_data[:features].empty?
    vehicle_data[:running_costs] = nil if vehicle_data[:running_costs].empty?
    
    vehicle_data
  end
  
  def extract_year_from_registration(registration)
    # Extract year from Irish registration (format: YYYY-C-#####)
    year_match = registration.match(/^(\d{2,3})/)
    if year_match
      year = year_match[1].to_i
      # Irish reg years: 00-49 = 2000-2049, 50-99 = 1950-1999
      if year >= 50
        "19#{year}"
      else
        "20#{year.to_s.rjust(2, '0')}"
      end
    else
      nil
    end
  end
  
  def parse_motorcheck_response(doc, registration)
    # Parse MotorCheck HTML response
    vehicle_data = {
      make: nil,
      model: nil,
      year: extract_year_from_registration(registration),
      engine_size: nil,
      fuel_type: nil,
      transmission: nil,
      performance: {},
      dimensions: {},
      features: [],
      running_costs: {}
    }
    
    # Try multiple selectors to find vehicle information
    # Make and Model - try various selectors
    [
      'h1.vehicle-title', 'h1.car-title', '.vehicle-name', '.car-name',
      'h1', '.title', '[data-vehicle]', '.vehicle-info h2'
    ].each do |selector|
      element = doc.css(selector).first
      if element
        text = element.text.strip
        if text.present? && text.length > 3
          parts = text.split(/\s+/)
          vehicle_data[:make] ||= parts.first
          vehicle_data[:model] ||= parts[1..-1].join(' ') if parts.length > 1
          break if vehicle_data[:make].present?
        end
      end
    end
    
    # Look for JSON data embedded in page
    doc.css('script').each do |script|
      script_text = script.text
      if script_text.include?('vehicle') || script_text.include?('carData')
        # Try to extract JSON
        json_match = script_text.match(/\{.*"make".*\}/m)
        if json_match
          begin
            json_data = JSON.parse(json_match[0])
            vehicle_data[:make] ||= json_data['make'] || json_data['manufacturer']
            vehicle_data[:model] ||= json_data['model']
            vehicle_data[:year] ||= json_data['year']
            vehicle_data[:engine_size] ||= json_data['engine_size'] || json_data['engine']
            vehicle_data[:fuel_type] ||= map_fuel_type(json_data['fuel_type'] || json_data['fuel'])
            vehicle_data[:transmission] ||= map_transmission(json_data['transmission'])
          rescue JSON::ParserError
            # Continue
          end
        end
      end
    end
    
    # Extract from tables and lists
    doc.css('table, dl, .specs, .specifications, .vehicle-details, .car-details').each do |section|
      # Try table rows
      section.css('tr').each do |row|
        cells = row.css('td, th')
        next if cells.length < 2
        
        label = cells[0].text.strip.downcase
        value = cells[1].text.strip
        
        extract_field_from_label(vehicle_data, label, value)
      end
      
      # Try definition lists
      section.css('dt, dd').each_slice(2) do |dt, dd|
        next unless dt && dd
        label = dt.text.strip.downcase
        value = dd.text.strip
        extract_field_from_label(vehicle_data, label, value)
      end
      
      # Try div-based specs
      section.css('.spec-item, .detail-item, [class*="spec"]').each do |item|
        label_elem = item.css('.label, .name, strong').first
        value_elem = item.css('.value, .data, span').last
        
        if label_elem && value_elem
          label = label_elem.text.strip.downcase
          value = value_elem.text.strip
          extract_field_from_label(vehicle_data, label, value)
        end
      end
    end
    
    # Clean up - remove empty hashes
    vehicle_data[:performance] = nil if vehicle_data[:performance].empty?
    vehicle_data[:dimensions] = nil if vehicle_data[:dimensions].empty?
    vehicle_data[:features] = nil if vehicle_data[:features].empty?
    vehicle_data[:running_costs] = nil if vehicle_data[:running_costs].empty?
    
    vehicle_data
  end
  
  def extract_field_from_label(vehicle_data, label, value)
    return if label.blank? || value.blank?
    
    case label
    when /make|manufacturer|brand/
      vehicle_data[:make] ||= value
    when /model/
      vehicle_data[:model] ||= value
    when /year|registration year|reg year/
      vehicle_data[:year] ||= value
    when /engine|engine size|capacity|cc|litre|liter/
      vehicle_data[:engine_size] ||= value
    when /fuel|fuel type|fuel type/
      vehicle_data[:fuel_type] ||= map_fuel_type(value)
    when /transmission|gear|gearbox|trans/
      vehicle_data[:transmission] ||= map_transmission(value)
    when /power|bhp|hp|kw/
      vehicle_data[:performance][:power] = value
    when /torque/
      vehicle_data[:performance][:torque] = value
    when /co2|emissions|co₂/
      vehicle_data[:performance][:co2_emissions] = value
      vehicle_data[:running_costs][:road_tax] = calculate_road_tax_from_co2(value)
    when /tax|road tax|motor tax|annual tax/
      vehicle_data[:running_costs][:road_tax] = value
    when /insurance|insurance group/
      vehicle_data[:running_costs][:insurance_group] = value
    when /consumption|mpg|fuel economy|l\/100km/
      vehicle_data[:running_costs][:fuel_consumption_combined] = value
    end
  end
  
  def map_fuel_type(fuel_type)
    return nil if fuel_type.blank?
    
    fuel_type = fuel_type.to_s.downcase
    case fuel_type
    when 'petrol', 'gasoline', 'unleaded'
      'Petrol'
    when 'diesel'
      'Diesel'
    when 'electric', 'ev', 'battery'
      'Electric'
    when 'hybrid', 'phev', 'plug-in hybrid'
      'Hybrid'
    else
      fuel_type.split.map(&:capitalize).join(' ')
    end
  end
  
  def map_transmission(transmission)
    return nil if transmission.blank?
    
    transmission = transmission.to_s.downcase
    case transmission
    when 'manual', 'm', 'manual gearbox'
      'Manual'
    when 'automatic', 'auto', 'a', 'automatic gearbox'
      'Automatic'
    else
      transmission.split.map(&:capitalize).join(' ')
    end
  end
  
  def calculate_road_tax_from_co2(co2_text)
    return 'Contact for details' if co2_text.blank?
    
    co2_value = co2_text.to_s.gsub(/[^\d]/, '').to_i
    
    # Irish road tax bands (2024 rates)
    if co2_value <= 0
      '€120 per year (Electric)'
    elsif co2_value <= 80
      '€120 per year'
    elsif co2_value <= 100
      '€170 per year'
    elsif co2_value <= 110
      '€180 per year'
    elsif co2_value <= 120
      '€200 per year'
    elsif co2_value <= 130
      '€270 per year'
    elsif co2_value <= 140
      '€280 per year'
    elsif co2_value <= 155
      '€390 per year'
    elsif co2_value <= 170
      '€570 per year'
    elsif co2_value <= 190
      '€750 per year'
    else
      '€1,200 per year'
    end
  end
  
  def basic_data_from_registration(registration)
    # Extract basic info from registration number when MotorCheck fails
    # Irish registration format: YYYY-C-#####
    year = extract_year_from_registration(registration)
    
    {
      make: nil,
      model: nil,
      year: year,
      engine_size: nil,
      fuel_type: nil,
      transmission: nil,
      performance: {},
      dimensions: {},
      features: [],
      running_costs: {}
    }
  end
end
