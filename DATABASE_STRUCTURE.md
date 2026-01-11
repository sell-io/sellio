# Database Structure Recommendations for Sell.io

This document outlines the recommended database structure for your DoneDeal-like classified ads website.

## Core Models Needed

### 1. **Categories** (for organizing listings)
```bash
rails generate scaffold Category name:string description:text icon:string
```

**Fields:**
- `name` (string) - e.g., "Motors", "Property", "Jobs"
- `description` (text) - Category description
- `icon` (string) - Emoji or icon identifier

**Migration additions you might want:**
- Add `slug` for SEO-friendly URLs
- Add `parent_id` for subcategories (self-referential)

---

### 2. **Users** (for user accounts - posting ads, messaging)
```bash
rails generate scaffold User email:string name:string phone:string encrypted_password:string
```

**Or use Devise gem** (recommended for authentication):
```bash
rails generate devise:install
rails generate devise User
```

**Additional fields you'll need:**
- `name` (string)
- `phone` (string)
- `location` (string) - User's location
- `avatar` (string) - Profile picture URL or use Active Storage

---

### 3. **Listings** (already exists, but needs enhancements)

**Current fields:**
- `title` (string) ✓
- `description` (text) ✓
- `price` (decimal) ✓
- `city` (string) ✓

**Additional fields needed:**
```bash
rails generate migration AddFieldsToListings category_id:references user_id:references status:string condition:string contact_email:string contact_phone:string views:integer featured:boolean
```

**Fields to add:**
- `category_id` (references) - Link to Category
- `user_id` (references) - Who posted the ad
- `status` (string) - "active", "sold", "expired", "pending"
- `condition` (string) - "new", "used", "refurbished"
- `contact_email` (string) - Contact email
- `contact_phone` (string) - Contact phone
- `views` (integer) - View counter
- `featured` (boolean) - Featured listing flag
- `expires_at` (datetime) - When listing expires

---

### 4. **Images** (for listing photos)
```bash
rails generate scaffold ListingImage listing:references image_url:string position:integer
```

**Or use Active Storage** (recommended - built into Rails):
- No scaffold needed, just add to Listing model:
  ```ruby
  has_many_attached :images
  ```

---

### 5. **Messages** (for buyer-seller communication)
```bash
rails generate scaffold Message listing:references sender:references{User} recipient:references{User} content:text read:boolean
```

**Fields:**
- `listing_id` (references) - Which listing
- `sender_id` (references) - Who sent the message
- `recipient_id` (references) - Who receives it
- `content` (text) - Message content
- `read` (boolean) - Read status

---

### 6. **Favorites** (for saved listings)
```bash
rails generate scaffold Favorite user:references listing:references
```

**Fields:**
- `user_id` (references)
- `listing_id` (references)
- Add unique index on `[user_id, listing_id]` to prevent duplicates

---

## Recommended Scaffold Commands (Run these in order)

### Step 1: Enhance Listings
```bash
rails generate migration AddFieldsToListings category_id:bigint user_id:bigint status:string condition:string contact_email:string contact_phone:string views:integer featured:boolean expires_at:datetime
```

### Step 2: Create Categories
```bash
rails generate scaffold Category name:string description:text icon:string slug:string
```

### Step 3: Create Users (or use Devise)
```bash
# Option A: Simple scaffold
rails generate scaffold User email:string name:string phone:string location:string

# Option B: Use Devise (recommended)
rails generate devise:install
rails generate devise User
rails generate migration AddFieldsToUsers name:string phone:string location:string
```

### Step 4: Create Messages
```bash
rails generate scaffold Message listing:references sender:references{User} recipient:references{User} content:text read:boolean
```

### Step 5: Create Favorites
```bash
rails generate scaffold Favorite user:references listing:references
```

### Step 6: Add Active Storage for Images
```bash
rails active_storage:install
```

---

## Model Associations (Add to your models)

### Listing Model
```ruby
class Listing < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :user, optional: true
  has_many_attached :images
  has_many :messages, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user
  
  enum status: { active: 'active', sold: 'sold', expired: 'expired', pending: 'pending' }
  enum condition: { new: 'new', used: 'used', refurbished: 'refurbished' }
  
  scope :active, -> { where(status: 'active') }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }
end
```

### Category Model
```ruby
class Category < ApplicationRecord
  has_many :listings, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
```

### User Model
```ruby
class User < ApplicationRecord
  has_many :listings, dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id'
  has_many :favorites, dependent: :destroy
  has_many :favorite_listings, through: :favorites, source: :listing
end
```

---

## Database Indexes (Add for performance)

After running migrations, add indexes:

```ruby
# In a new migration
rails generate migration AddIndexesToDatabase

# Then add:
add_index :listings, :category_id
add_index :listings, :user_id
add_index :listings, :status
add_index :listings, :city
add_index :listings, [:status, :created_at]
add_index :listings, :featured
add_index :messages, [:listing_id, :created_at]
add_index :favorites, [:user_id, :listing_id], unique: true
```

---

## Next Steps

1. Run the scaffold commands above
2. Run `rails db:migrate`
3. Update your models with the associations
4. Update your controllers to handle the new relationships
5. Add image upload functionality using Active Storage
6. Implement user authentication (if using Devise)

---

## Notes for Valentina Database Viewer

When viewing in Valentina:
- All tables will be visible after migrations
- Foreign key relationships will show as links between tables
- You can see indexes in the table structure view
- Active Storage creates `active_storage_blobs` and `active_storage_attachments` tables automatically
