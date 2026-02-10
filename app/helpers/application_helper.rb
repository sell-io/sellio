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
end
