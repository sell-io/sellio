# frozen_string_literal: true

namespace :listings do
  desc "Delete all listings that are not in the Motors (car) category; keep only car ads"
  task keep_cars_only: :environment do
    motors = Category.find_by(name: "Motors")
    unless motors
      puts "Motors category not found. No listings deleted."
      next
    end

    non_car = Listing.where.not(category_id: motors.id)
    count = non_car.count
    non_car.destroy_all
    puts "Deleted #{count} non-car listing(s). Only Motors listings remain."
  end
end
