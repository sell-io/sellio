# Create favicon-32.png and favicon-16.png from TabIcon.png

## Steps to Create HUGE Favicon:

### 1. Design Requirements:
- **Icon must fill 90-92% of canvas** (8-12% padding MAX)
- **Thicken the icon aggressively** - make it bold and wide
- **Use a background shape** (solid green square, rounded square, or circle)
- **No thin strokes** - they disappear at 16px
- **High contrast** - think app icon, not brand logo

### 2. Export from TabIcon.png:

**Option A: Using Image Editor (Photoshop, GIMP, Canva, etc.)**
1. Open `TabIcon.png` (your 1024x1024 or 512x512 design)
2. Make sure icon fills 90-92% of canvas (almost edge-to-edge)
3. Export as **32x32 pixels** → Save as `public/favicon-32.png`
4. Export as **16x16 pixels** → Save as `public/favicon-16.png`

**Option B: Using Online Tool (EASIEST)**
1. Go to: https://realfavicongenerator.net/
2. Upload `TabIcon.png`
3. In "Favicon for Desktop Browsers":
   - Set **Padding to 8-12%** (NOT 20%!)
   - Download the generated files
4. Rename and place:
   - `favicon-32x32.png` → `public/favicon-32.png`
   - `favicon-16x16.png` → `public/favicon-16.png`

### 3. Key Points:
- ✅ Icon almost touches edges (8-12% padding)
- ✅ Bold, thick strokes (no thin lines)
- ✅ Solid background shape
- ✅ High contrast
- ✅ Export at exact sizes: 32x32 and 16x16

### 4. After Creating Files:
1. Place `favicon-32.png` and `favicon-16.png` in `public/` folder
2. Hard refresh browser: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
3. Or test in incognito mode

The HTML is already configured to use these files!
