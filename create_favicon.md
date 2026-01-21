# Creating a Properly Sized Favicon

The current `TabIcon.png` is 2MB and too large for a favicon. You need to create a 32x32 version with ~20% padding.

## Requirements:
- **Size**: 32 × 32 pixels
- **Padding**: ~20% (so the actual icon content should be about 26x26 pixels centered)
- **Format**: PNG with transparent background
- **File**: Save as `public/favicon-32x32.png` or `public/favicon.ico`

## How to create it:

### Option 1: Using an online tool
1. Go to https://favicon.io/favicon-converter/ or similar
2. Upload your 512x512 design
3. Export as 32x32 PNG
4. Save to `public/favicon-32x32.png`

### Option 2: Using image editing software
1. Open your 512x512 design
2. Resize to 32x32 pixels
3. Ensure ~20% padding (icon content ~26x26)
4. Export as PNG with transparency
5. Save to `public/favicon-32x32.png`

### Option 3: Using ImageMagick (if installed)
```bash
# Resize to 32x32 with padding
convert public/TabIcon.png -resize 26x26 -gravity center -extent 32x32 -background transparent public/favicon-32x32.png
```

Once you have the 32x32 version, update `app/views/layouts/application.html.erb` to use:
```erb
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
```
