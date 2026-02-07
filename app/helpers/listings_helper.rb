module ListingsHelper
  # Subcategories per category name (used when creating/editing a listing).
  # Motors uses vehicle types; other categories use these lists.
  CATEGORY_SUBCATEGORIES = {
    "Motors" => %w[Car Van Truck Tractor Motorcycle Scooter Quad Caravan Trailer Boat Other],
    "Property" => %w[House Apartment Land Commercial Room Other],
    "Electronics" => %w[Phone Computer TV Audio Camera Gaming Other],
    "Furniture" => %w[Sofa Table Bed Chair Storage Garden Other],
    "Fashion" => %w[Men Women Kids Shoes Accessories Other],
    "Hobbies" => %w[Sports Games Books Collectibles Other],
    "Animals" => %w[Dogs Cats Birds Fish Small\ animals Other],
    "Services" => %w[Babysitting Cleaning Car\ Valeting Gardening Tutoring Other],
    "Farming" => %w[Equipment Livestock Seeds\ &\ Feed Other],
    "Music + Education" => %w[Instruments Books\ &\ Courses Tuition Other],
    "Sport + Hobbies" => %w[Sports\ Equipment Gym Outdoor Other],
    "Baby + Kids" => %w[Clothing Toys Furniture Equipment Other]
  }.freeze

  def irish_counties
    ApplicationHelper::IRISH_COUNTIES
  end

  def category_subcategories_json
    CATEGORY_SUBCATEGORIES.to_json
  end

  def subcategories_for_category(category)
    return [] unless category
    CATEGORY_SUBCATEGORIES[category.name] || []
  end
end
