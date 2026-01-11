# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create categories if they don't exist
categories = [
  { name: "Motors", description: "Cars, Vans, Motorcycles", icon: "🚗" },
  { name: "Property", description: "Houses, Apartments, Land", icon: "🏠" },
  { name: "Jobs", description: "Full-time, Part-time, Contract", icon: "💼" },
  { name: "Electronics", description: "Phones, Computers, TVs", icon: "📱" },
  { name: "Furniture", description: "Home & Garden", icon: "🪑" },
  { name: "Fashion", description: "Clothing & Accessories", icon: "👕" },
  { name: "Hobbies", description: "Sports, Games, Books", icon: "🎮" },
  { name: "Pets", description: "Dogs, Cats, Birds", icon: "🐾" },
  { name: "Services", description: "Babysitting, Car Valeting, Cleaning, etc.", icon: "🔧" }
]

categories.each do |cat_data|
  Category.find_or_create_by!(name: cat_data[:name]) do |category|
    category.description = cat_data[:description]
    category.icon = cat_data[:icon]
  end
end

puts "✅ Categories seeded successfully!"
