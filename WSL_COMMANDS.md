# WSL Commands for Sell.io Database Setup

Copy and paste these commands one at a time into your WSL terminal.

## Step 1: Navigate to your project directory
```bash
cd /mnt/c/Users/Admin/Downloads/Sellio-main/Sellio-main
```

---

## Step 2: Add fields to existing Listings table
```bash
rails generate migration AddFieldsToListings category_id:bigint user_id:bigint status:string condition:string contact_email:string contact_phone:string views:integer featured:boolean expires_at:datetime
```

---

## Step 3: Create Categories scaffold
```bash
rails generate scaffold Category name:string description:text icon:string slug:string
```

---

## Step 4: Create Users scaffold
```bash
rails generate scaffold User email:string name:string phone:string location:string
```

---

## Step 5: Create Messages scaffold
```bash
rails generate scaffold Message listing:references sender_id:bigint recipient_id:bigint content:text read:boolean
```

**IMPORTANT:** After generating, you need to edit the migration file to add foreign keys. The migration file will be in `db/migrate/XXXXXX_create_messages.rb`. Open it and change it to look like this:

```ruby
class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.text :content
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
```

**OR** if the migration already exists and is broken, delete it first:
```bash
# Find and delete the broken migration file
rm db/migrate/*_create_messages.rb
# Then run the generate command above again
```

---

## Step 6: Create Favorites scaffold
```bash
rails generate scaffold Favorite user:references listing:references
```

---

## Step 7: Set up Active Storage for images
```bash
rails active_storage:install
```

---

## Step 8: Run all migrations
```bash
rails db:migrate
```

---

## Step 9: (Optional) Create indexes for better performance
```bash
rails generate migration AddIndexesToDatabase
```

Then edit the generated migration file and add this content:

```ruby
class AddIndexesToDatabase < ActiveRecord::Migration[8.1]
  def change
    add_index :listings, :category_id
    add_index :listings, :user_id
    add_index :listings, :status
    add_index :listings, :city
    add_index :listings, [:status, :created_at]
    add_index :listings, :featured
    add_index :messages, [:listing_id, :created_at]
    add_index :favorites, [:user_id, :listing_id], unique: true
  end
end
```

Then run:
```bash
rails db:migrate
```

---

## Step 10: (Optional) Seed some test data
```bash
rails generate migration AddSampleData
```

Then edit the generated migration file and add sample categories:

```ruby
class AddSampleData < ActiveRecord::Migration[8.1]
  def up
    Category.create!(name: "Motors", description: "Cars, Vans, Motorcycles", icon: "🚗", slug: "motors")
    Category.create!(name: "Property", description: "Houses, Apartments, Land", icon: "🏠", slug: "property")
    Category.create!(name: "Jobs", description: "Full-time, Part-time, Contract", icon: "💼", slug: "jobs")
    Category.create!(name: "Electronics", description: "Phones, Computers, TVs", icon: "📱", slug: "electronics")
    Category.create!(name: "Furniture", description: "Home & Garden", icon: "🪑", slug: "furniture")
    Category.create!(name: "Fashion", description: "Clothing & Accessories", icon: "👕", slug: "fashion")
    Category.create!(name: "Hobbies", description: "Sports, Games, Books", icon: "🎮", slug: "hobbies")
    Category.create!(name: "Pets", description: "Dogs, Cats, Birds", icon: "🐾", slug: "pets")
  end

  def down
    Category.destroy_all
  end
end
```

Then run:
```bash
rails db:migrate
```

---

## Notes:
- Make sure you're in the correct directory (Step 1)
- Run each command separately and wait for it to complete
- If you get any errors, check the error message and let me know
- After migrations, you can view the database structure in Valentina
