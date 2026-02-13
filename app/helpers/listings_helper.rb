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
      Holiday\ let For\ Sale To\ Let Site Bungalow Cottage
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
      Tractors Machinery Implements Livestock Cattle Sheep Pigs Poultry
      Seeds\ &\ feed Hay\ &\ straw Fencing Irrigation Tools Buildings
      Veterinary ATVs\ &\ quads Trailers Generators Sprayers
      Slurry\ equipment Silage\ equipment Tillage Dairy Poultry\ equipment
      Other
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

  def pagination_params
    # Use to_h or to_unsafe_h to convert to hash
    # params.permit(:search, :category, :status, :sort, :direction).to_h
    # Or if you need to include all parameters
    params.to_unsafe_h
  end

end
