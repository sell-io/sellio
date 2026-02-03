module ApplicationHelper
  include ActionView::Helpers::NumberHelper

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
