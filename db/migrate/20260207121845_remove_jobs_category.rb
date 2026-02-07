class RemoveJobsCategory < ActiveRecord::Migration[8.1]
  def up
    jobs = Category.find_by(name: "Jobs")
    if jobs
      Listing.where(category_id: jobs.id).update_all(category_id: nil)
      jobs.destroy
    end
  end

  def down
    Category.find_or_create_by(name: "Jobs") do |cat|
      cat.description = "Full-time, Part-time, Contract"
      cat.icon = "💼"
    end
  end
end
