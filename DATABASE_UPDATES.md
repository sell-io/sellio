# Database Updates for Categories, Images, and Listings

Run these commands in WSL to update your database:

## Step 1: Navigate to your project
```bash
cd /home/alex/sellio
```

## Step 2: Run the migration to add category_id and user_id to listings
```bash
rails db:migrate
```

This will run the migration: `20260109190000_add_category_and_user_to_listings.rb`

## Step 3: Set up Active Storage for image uploads
```bash
rails active_storage:install
```

## Step 4: Run the Active Storage migration
```bash
rails db:migrate
```

This creates the `active_storage_blobs` and `active_storage_attachments` tables.

---

## What These Migrations Do:

1. **Add Category and User to Listings:**
   - Adds `category_id` foreign key to link listings to categories
   - Adds `user_id` foreign key to link listings to users
   - Creates indexes for better performance

2. **Active Storage:**
   - Enables image uploads for listings
   - Creates tables to store image files
   - Allows multiple images per listing

---

## After Running:

- Listings can now be assigned to categories
- Listings can be linked to users (who posted them)
- Users can upload multiple images per listing
- Categories on homepage are clickable and filter listings

---

## Testing:

1. Create a listing and select a category
2. Upload images when creating/editing a listing
3. Click a category on the homepage to see filtered listings
4. View a listing detail page to see all images
