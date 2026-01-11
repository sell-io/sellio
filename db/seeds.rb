ActiveStorage::Blob.create!([
  {byte_size: 179008, checksum: "OeObwisWsP3cJqnXfm82DA==", content_type: "image/jpeg", filename: "Mercedes.jpg", key: "nbcjadgtz4gcbdn9frb5h5wedcuu", metadata: {"identified" => true, "analyzed" => true}, service_name: "local"},
  {byte_size: 323400, checksum: "x3JzY85MJ7ym/fSs6hyp0A==", content_type: "image/webp", filename: "Polo.webp", key: "pb4ch6w3qpt0e9jqw0626y9rnr95", metadata: {"identified" => true, "analyzed" => true}, service_name: "local"}
])
User.create!([
  {email: "adrianasecas12@gmail.com", encrypted_password: "$2a$12$Qgx5jypB6UgdUmJTdcjws.5UDjj8E3tw6jz88jAO/vAThvmVbaYWm", location: "Limerick,Ireland", name: "Adriana Secas", phone: "+353892126853", remember_created_at: nil, reset_password_sent_at: nil, reset_password_token: nil},
  {email: "alexsidorov05@gmail.com", encrypted_password: "$2a$12$AuzqtaAAC4yWqgrCNhEOI.jyj0dw7zGATvoz2pgm0oirmj305mRQi", location: "Limerick,Ireland", name: "Alex Sidorov", phone: "+353852406366", remember_created_at: nil, reset_password_sent_at: nil, reset_password_token: nil}
])
Category.create!([
  {description: "Cars, Vans, Motorcycles", icon: "🚗", name: "Motors", slug: nil},
  {description: "Houses, Apartments, Land", icon: "🏠", name: "Property", slug: nil},
  {description: "Full-time, Part-time, Contract", icon: "💼", name: "Jobs", slug: nil},
  {description: "Phones, Computers, TVs", icon: "📱", name: "Electronics", slug: nil},
  {description: "Home & Garden", icon: "🪑", name: "Furniture", slug: nil},
  {description: "Clothing & Accessories", icon: "👕", name: "Fashion", slug: nil},
  {description: "Sports, Games, Books", icon: "🎮", name: "Hobbies", slug: nil},
  {description: "Dogs, Cats, Birds", icon: "🐾", name: "Pets", slug: nil},
  {description: "Babysitting, Car Valeting, Cleaning, etc.", icon: "🔧", name: "Services", slug: nil}
])
Listing.create!([
  {category_id: 1, city: "Limerick", condition: nil, contact_email: nil, contact_phone: nil, description: "2021 Volkswagen Polo grey ", expires_at: nil, extra_fields: {"make" => "Volkswagen", "year" => "2021", "mileage" => "50000", "fuel_type" => "Petrol", "engine_size" => "1", "transmission" => "Manual", "previous_owners" => "0"}, featured: nil, price: "20000.0", status: nil, title: "Volkswagen Polo", user_id: 2, views: nil}
])
