# Migration for Category-Specific Fields

Run this command in WSL to add category-specific fields to listings:

```bash
cd /mnt/c/Users/Admin/Downloads/Sellio-main/Sellio-main
rails db:migrate
```

This will add an `extra_fields` JSON column to the listings table, which allows storing different fields for different categories (like car details for Motors category).

## What This Enables:

- **Motors/Cars**: License plate, mileage, engine size, previous owners, make, model, year, fuel type, transmission
- **Future categories**: Can easily add more category-specific fields later

After running the migration, you can:
1. Create listings with car-specific details
2. View car details on listing pages
3. Contact sellers directly from listings
