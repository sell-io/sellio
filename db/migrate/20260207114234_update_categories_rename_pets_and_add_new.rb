class UpdateCategoriesRenamePetsAndAddNew < ActiveRecord::Migration[8.1]
  def up
    # Rename Pets to Animals
    Category.where(name: "Pets").update_all(name: "Animals", description: "Dogs, Cats, Birds, and more", updated_at: Time.current)

    # Add new categories if they don't exist
    [
      { name: "Farming", description: "Equipment, Livestock, Seeds & Feed", icon: "🚜" },
      { name: "Music + Education", description: "Instruments, Books, Tuition", icon: "🎵" },
      { name: "Sport + hobbies", description: "Sports Equipment, Gym, Outdoor", icon: "⚽" },
      { name: "baby + kids", description: "Clothing, Toys, Furniture, Equipment", icon: "👶" }
    ].each do |attrs|
      Category.find_or_create_by(name: attrs[:name]) do |c|
        c.description = attrs[:description]
        c.icon = attrs[:icon]
      end
    end
  end

  def down
    Category.where(name: "Animals").update_all(name: "Pets", description: "Dogs, Cats, Birds", updated_at: Time.current)
    Category.where(name: ["Farming", "Music + Education", "Sport + hobbies", "baby + kids"]).destroy_all
  end
end
