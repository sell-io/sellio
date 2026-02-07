class RenameBabyKidsAndSportHobbiesCategories < ActiveRecord::Migration[8.1]
  def up
    Category.where(name: "baby + kids").update_all(name: "Baby + Kids", updated_at: Time.current)
    Category.where(name: "Sport + hobbies").update_all(name: "Sport + Hobbies", updated_at: Time.current)
  end

  def down
    Category.where(name: "Baby + Kids").update_all(name: "baby + kids", updated_at: Time.current)
    Category.where(name: "Sport + Hobbies").update_all(name: "Sport + hobbies", updated_at: Time.current)
  end
end
