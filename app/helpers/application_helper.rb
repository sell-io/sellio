module ApplicationHelper
  include ActionView::Helpers::NumberHelper

  # Icons for categories (Buy dropdown and anywhere else). Key is category name (case-insensitive match).
  CATEGORY_ICONS = {
    "motors" => "🚗",
    "properties" => "🏠",
    "property" => "🏠",
    "services" => "🔧",
    "electronics" => "📱",
    "animals" => "🐾",
    "furniture" => "🪑",
    "farming" => "🚜",
    "music + education" => "🎵",
    "sport + hobbies" => "⚽",
    "baby + kids" => "👶"
  }.freeze

  def category_icon(category)
    return "" unless category.respond_to?(:name) && category.name.present?
    key = category.name.to_s.strip.downcase
    CATEGORY_ICONS[key] || "📦"
  end

  # Irish counties – used for user location (signup/edit) and listing county so they look the same in ads
  IRISH_COUNTIES = %w[
    Antrim Armagh Carlow Cavan Clare Cork Derry Donegal Down Dublin
    Fermanagh Galway Kerry Kildare Kilkenny Laois Leitrim Limerick Longford Louth
    Mayo Meath Monaghan Offaly Roscommon Sligo Tipperary Tyrone Waterford
    Westmeath Wexford Wicklow
  ].freeze

  def irish_counties
    IRISH_COUNTIES
  end

  # Builds a wa.me click-to-chat link from a stored phone number (handles Irish local "08X..."
  # format, "+353..." and "353..." forms) with a pre-filled message about the listing.
  def whatsapp_chat_link(phone, listing)
    digits = phone.to_s.gsub(/\D/, "")
    return nil if digits.blank?

    international = if digits.start_with?("353")
      digits
    elsif digits.start_with?("0")
      "353#{digits[1..]}"
    else
      digits
    end

    message = "Hi, I'm interested in your listing \"#{listing.title}\" on Dealo: #{listing_url(listing)}"
    "https://wa.me/#{international}?text=#{ERB::Util.url_encode(message)}"
  end
end
