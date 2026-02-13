module ListingsHelper
  # Subcategories per category (DoneDeal-style; used when creating/editing a listing).
  CATEGORY_SUBCATEGORIES = {
    "Motors" => %w[
      Car Van Truck Tractor Motorcycle Scooter Quad Caravan Trailer Boats
      Jet\ skis Campers Coaches Buses Commercials Vintage\ Cars Breaking\ &\ Repairables
      Car\ Parts Plant\ Machinery Parts\ &\ Accessories Other\ Motor Other
    ],
    "Property" => %w[
      House Apartment Land Commercial Room Studio Shared\ accommodation
      Holiday\ let For\ Sale To\ Let Site Bungalow Cottage Mobile\ home
      Duplex Detached Semi-detached Terraced Other
    ],
    "Electronics" => %w[
      Phone Computer Laptop Tablet TV Audio Camera Gaming Console
      Headphones Smartwatch Printer Monitor Home\ Office Software
      Cables\ &\ Accessories Smart\ home Wearables Drones
      E-readers Batteries\ &\ Chargers Other
    ],
    "Furniture" => %w[
      Sofa Table Bed Chair Desk Wardrobe Storage Garden Outdoor
      Shelving Lighting Kitchen Bedroom Living\ Room Bathroom Dining\ Room
      Home\ Office Catering\ Fittings Carpets\ &\ Rugs Curtains
      Mattresses Mirrors Other
    ],
    "Fashion" => %w[
      Men Women Kids Unisex Shoes Bags Accessories Jewellery Watches
      Coats Jackets Sportswear Mens\ Clothes Womens\ Clothes Childrens\ Clothes
      Dresses Tops Trousers Shorts Swimwear Underwear Hats
      Belts Scarves Other
    ],
    "Hobbies" => %w[
      Sports Games Books Collectibles Art\ supplies Crafts Musical\ instruments
      Board\ games Puzzles Cards Comics Memorabilia Stamps Coins
      Model\ kits Antiques Vinyl\ &\ CDs Film\ &\ Photography Other
    ],
    "Animals" => %w[
      Dogs Cats Birds Fish Small\ animals Reptiles Equine Livestock
      Pet\ supplies Dog\ supplies Cat\ supplies Bird\ supplies
      Aquarium Equine\ supplies Other
    ],
    "Services" => %w[
      Babysitting Cleaning Car\ valeting Gardening Tutoring Plumbing
      Electrical Moving Beauty Repair Catering Events Photography
      Painting\ &\ Decorating Carpentry Landscaping Pet\ care
      Driving\ lessons IT\ &\ Web Legal\ &\ Accounting Other
    ],
    "Farming" => %w[
      Tractors Livestock Farm\ Machinery Bedding\ &\ Feed Farmers\ Market
      Farmers\ Noticeboard Farm\ Services Farm\ Sheds Farm\ Tools
      Feeding\ Equipment Fencing\ Equipment Fertilisers Poultry Vintage\ Machinery
      Beef\ Cattle Sheep Pigs Cattle\ Trailers Hay\ &\ Forage Silage\ Grabs
      Mowers Ploughs Agitators Other\ Farm\ Machinery Seeds\ &\ feed
      Hay\ &\ straw Fencing Irrigation Buildings Veterinary ATVs\ &\ quads
      Trailers Generators Sprayers Slurry\ equipment Silage\ equipment
      Tillage Dairy Poultry\ equipment Implements Other\ Farming Other
    ],
    "Music + Education" => %w[
      Guitar Piano Drums Keyboard Strings Brass Woodwind Microphones
      Headphones Speakers Audio\ interface Amplifier Books\ &\ courses Tuition
      Sheet\ music Recording\ equipment DJ\ equipment Synthesizer
      Ukulele Banjo Mandolin Music\ stands Cases\ &\ Bags Other
    ],
    "Sport + Hobbies" => %w[
      Bike Cycling Running Gym Outdoor Sports\ equipment Camping Fishing
      Golf Tennis Football GAA Rugby Water\ sports Winter\ sports Hiking
      Yoga Fitness Skateboard Swimming Equestrian Martial\ arts
      Gymnastics Athletics Badminton Basketball Hurling Golf\ clubs
      Ski\ &\ Snowboard Other
    ],
    "Baby + Kids" => %w[
      Pram Pushchair Stroller Clothing Toys Furniture Crib Cot High\ chair
      Car\ seat Baby\ carrier Feeding Bottles Nursery Books Games
      Bikes\ &\ trikes Outdoor\ play Safety\ equipment Maternity
      Baby\ clothes Kids\ clothes School\ supplies Other
    ]
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

  # Icon for a subcategory (e.g. in marketplace browse). Key: "CategoryName|SubcategoryName" downcased.
  def subcategory_icon(category_name, subcategory_name)
    return "📦" if subcategory_name.blank?
    key = "#{category_name}|#{subcategory_name}".downcase
    ic = subcategory_icon_map[key]
    return ic if ic.present?
    return "🚗" if category_name.to_s.downcase.include?("motor")
    return "🚜" if category_name.to_s.downcase.include?("farming")
    "📦"
  end

  def subcategory_icon_map
    @subcategory_icon_map ||= {
      "motors|car" => "🚗", "motors|van" => "🚐", "motors|truck" => "🚚", "motors|tractor" => "🚜",
      "motors|motorcycle" => "🏍️", "motors|scooter" => "🛵", "motors|boat" => "⛵", "motors|boats" => "⛵",
      "motors|jet skis" => "🛥️", "motors|caravan" => "🚐", "motors|trailer" => "🚛",
      "motors|commercials" => "🚛", "motors|vintage cars" => "🚗", "motors|parts & accessories" => "🔧",
      "farming|tractors" => "🚜", "farming|livestock" => "🐄", "farming|farm machinery" => "🚜",
      "farming|poultry" => "🐔", "farming|sheep" => "🐑", "farming|pigs" => "🐷", "farming|beef cattle" => "🐄",
      "farming|farm sheds" => "🏠", "farming|farm tools" => "🔧"
    }.freeze
  end

  # Farming: 4 sections, category-level icon in header only, tiles text-only.
  FARMING_SECTIONS = {
    "Machinery" => %w[Tractors Farm\ Machinery Mowers Ploughs Vintage\ Machinery Implements Sprayers Poultry\ equipment],
    "Livestock" => %w[Livestock Beef\ Cattle Sheep Pigs Poultry],
    "Supplies & Feed" => %w[Bedding\ &\ Feed Seeds\ &\ feed Hay\ &\ straw Feeding\ Equipment Fertilisers],
    "Infrastructure" => %w[Farm\ Sheds Farm\ Tools Fencing Fencing\ Equipment Irrigation Buildings]
  }.freeze

  FARMING_SECTION_HEADERS = {
    "Machinery" => { icon: "tractor", subtitle: "Tractors, implements & equipment" },
    "Livestock" => { icon: "cow", subtitle: "Cattle, sheep, pigs & poultry" },
    "Supplies & Feed" => { icon: "package", subtitle: "Feed, seeds & fertilisers" },
    "Infrastructure" => { icon: "warehouse", subtitle: "Sheds, fencing & buildings" }
  }.freeze

  def farming_sections
    FARMING_SECTIONS.transform_values { |names| names.map { |name| { name: name } } }
  end

  def farming_section_header(heading)
    FARMING_SECTION_HEADERS[heading.to_s] || { icon: "circle", subtitle: nil }
  end

  def farming_section_slug(heading)
    heading.to_s.downcase.gsub(/\s+&\s+/, "-").gsub(/\s+/, "-").tr(" ", "-")
  end

  # Motors grouped into 3 sections. Category-level icon only (in section header), tiles are text-only.
  MOTORS_SECTIONS = {
    "Vehicles" => %w[Car Van Truck Motorcycle Scooter Quad Vintage\ Cars Commercials],
    "Leisure & Transport" => %w[Caravan Trailer Boats Jet\ skis Campers Coaches Buses],
    "Machinery & Parts" => %w[Tractor Plant\ Machinery Breaking\ &\ Repairables Car\ Parts Parts\ &\ Accessories Other\ Motor Other]
  }.freeze

  # Section heading: large icon (Lucide name) + optional subtitle.
  MOTORS_SECTION_HEADERS = {
    "Vehicles" => { icon: "car", subtitle: "Cars, vans, trucks & more" },
    "Leisure & Transport" => { icon: "ship", subtitle: "Boats, caravans, coaches & buses" },
    "Machinery & Parts" => { icon: "wrench", subtitle: "Parts, machinery & repairs" }
  }.freeze

  def motors_section_header(heading)
    MOTORS_SECTION_HEADERS[heading.to_s] || { icon: "circle", subtitle: nil }
  end

  def motors_sections(motors_cat)
    return {} unless motors_cat
    MOTORS_SECTIONS.transform_values { |names| names.map { |name| { name: name } } }
  end

  # Marketplace: single section, section-level icon in header, tiles text-only.
  MARKETPLACE_SECTION_HEADER = { icon: "shopping-bag", subtitle: "Browse by category" }.freeze

  def marketplace_section_header
    MARKETPLACE_SECTION_HEADER
  end

  def marketplace_cards_items(categories)
    return [] unless categories.respond_to?(:each)
    categories.map { |cat| { name: cat.name, id: cat.id } }
  end

  def pagination_params
    # Use to_h or to_unsafe_h to convert to hash
    # params.permit(:search, :category, :status, :sort, :direction).to_h
    # Or if you need to include all parameters
    params.to_unsafe_h
  end

end
