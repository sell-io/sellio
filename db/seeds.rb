# Create ActiveStorage blobs if they don't exist
ActiveStorage::Blob.find_or_create_by(key: "nbcjadgtz4gcbdn9frb5h5wedcuu") do |blob|
  blob.byte_size = 179008
  blob.checksum = "OeObwisWsP3cJqnXfm82DA=="
  blob.content_type = "image/jpeg"
  blob.filename = "Mercedes.jpg"
  blob.metadata = {"identified" => true, "analyzed" => true}
  blob.service_name = "local"
end

ActiveStorage::Blob.find_or_create_by(key: "pb4ch6w3qpt0e9jqw0626y9rnr95") do |blob|
  blob.byte_size = 323400
  blob.checksum = "x3JzY85MJ7ym/fSs6hyp0A=="
  blob.content_type = "image/webp"
  blob.filename = "Polo.webp"
  blob.metadata = {"identified" => true, "analyzed" => true}
  blob.service_name = "local"
end

# Create users if they don't exist
User.find_or_create_by(email: "adrianasecas12@gmail.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.location = "Limerick,Ireland"
  user.name = "Adriana Secas"
  user.phone = "+353892126853"
end

User.find_or_create_by(email: "alexsidorov05@gmail.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.location = "Limerick,Ireland"
  user.name = "Alex Sidorov"
  user.phone = "+353852406366"
end

# Create categories if they don't exist
Category.find_or_create_by(name: "Motors") do |cat|
  cat.description = "Cars, Vans, Motorcycles"
  cat.icon = "🚗"
  cat.slug = nil
end

Category.find_or_create_by(name: "Property") do |cat|
  cat.description = "Houses, Apartments, Land"
  cat.icon = "🏠"
  cat.slug = nil
end

Category.find_or_create_by(name: "Jobs") do |cat|
  cat.description = "Full-time, Part-time, Contract"
  cat.icon = "💼"
  cat.slug = nil
end

Category.find_or_create_by(name: "Electronics") do |cat|
  cat.description = "Phones, Computers, TVs"
  cat.icon = "📱"
  cat.slug = nil
end

Category.find_or_create_by(name: "Furniture") do |cat|
  cat.description = "Home & Garden"
  cat.icon = "🪑"
  cat.slug = nil
end

Category.find_or_create_by(name: "Fashion") do |cat|
  cat.description = "Clothing & Accessories"
  cat.icon = "👕"
  cat.slug = nil
end

Category.find_or_create_by(name: "Hobbies") do |cat|
  cat.description = "Sports, Games, Books"
  cat.icon = "🎮"
  cat.slug = nil
end

Category.find_or_create_by(name: "Pets") do |cat|
  cat.description = "Dogs, Cats, Birds"
  cat.icon = "🐾"
  cat.slug = nil
end

Category.find_or_create_by(name: "Services") do |cat|
  cat.description = "Babysitting, Car Valeting, Cleaning, etc."
  cat.icon = "🔧"
  cat.slug = nil
end

# Create listing if it doesn't exist
motors_category = Category.find_by(name: "Motors")
alex_user = User.find_by(email: "alexsidorov05@gmail.com")

if motors_category && alex_user
  Listing.find_or_create_by(title: "Volkswagen Polo", user_id: alex_user.id) do |listing|
    listing.category_id = motors_category.id
    listing.city = "Limerick"
    listing.description = "2021 Volkswagen Polo grey "
    listing.price = 20000.0
    listing.extra_fields = {"make" => "Volkswagen", "year" => "2021", "mileage" => "50000", "fuel_type" => "Petrol", "engine_size" => "1", "transmission" => "Manual", "previous_owners" => "0"}
  end
end
