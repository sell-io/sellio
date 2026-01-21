# Creating a Bigger Favicon

The current `TabIcon.png` is 1536x1024. To make the favicon appear **LOT bigger** in browser tabs, you need to create a version with **less padding** and **larger icon content**.

## Requirements for a Bigger Icon:
- **Size**: 64 × 64 or 96 × 96 pixels (larger than standard 32x32)
- **Padding**: ~5-10% (much less padding = bigger visible icon)
- **Format**: PNG with transparent background
- **File**: Save as `public/TabIcon.png` (replace existing) or `public/favicon-64x64.png`

## How to create it:

### Option 1: Using an online tool
1. Go to https://favicon.io/favicon-converter/ or https://realfavicongenerator.net/
2. Upload your 512x512 design
3. **Set padding to minimum (5-10%)** - this is key for a bigger icon
4. Export as 64x64 or 96x96 PNG
5. Save to `public/TabIcon.png`

### Option 2: Using image editing software (Recommended)
1. Open your 512x512 design
2. **Crop to remove excessive padding** - make the icon fill more of the canvas
3. Resize to **64x64 or 96x96 pixels** (not 32x32)
4. Ensure minimal padding (5-10% max)
5. Export as PNG with transparency
6. Save to `public/TabIcon.png`

### Option 3: Using ImageMagick (if installed)
```bash
# Crop to center and resize to 64x64 with minimal padding
convert public/TabIcon.png -gravity center -crop 80%x80%+0+0 -resize 64x64 -background transparent public/TabIcon.png
```

## Key Points:
- **Less padding = bigger visible icon** in the browser tab
- **Larger source size (64x64 or 96x96)** helps browsers render it better
- The current TabIcon.png has too much padding, making the icon appear tiny
