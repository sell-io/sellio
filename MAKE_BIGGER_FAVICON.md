# Making the Favicon 3x Bigger

The favicon appears small because **the icon content only takes up a small portion of the image**. To make it 3x bigger, you need to create a new favicon where the icon fills **90-95% of the canvas** (almost no padding).

## The Problem:
Your current `TabIcon.png` has the icon centered with lots of empty space around it. When browsers scale it down to 16x16 or 32x32, that empty space makes the icon appear tiny.

## The Solution:
Create a new favicon where the icon fills almost the entire image.

### Steps to Create a 3x Bigger Favicon:

1. **Open your original icon design** (the one with the actual logo/icon)

2. **Crop it tightly** - Remove ALL the padding/empty space around the icon
   - The icon should go almost edge-to-edge
   - Leave only 2-5% padding maximum

3. **Resize to 64x64 or 96x96 pixels**
   - Use image editing software (Photoshop, GIMP, Canva, etc.)
   - Make sure the icon fills 90-95% of the canvas

4. **Save as PNG with transparency**
   - Replace `public/TabIcon.png` with this new version

### Quick Method Using Online Tools:

1. Go to https://realfavicongenerator.net/
2. Upload your icon (the one with minimal padding)
3. In "Favicon for Desktop Browsers":
   - Set "Padding" to **0% or 2%** (NOT 20%!)
   - Set size to **64x64 or 96x96**
4. Download and replace `public/TabIcon.png`

### Example:
- ❌ **Bad**: Icon is 20x20 pixels centered in a 64x64 canvas (appears tiny)
- ✅ **Good**: Icon is 60x60 pixels in a 64x64 canvas (appears 3x bigger!)

The key is: **Less padding = Bigger visible icon** in the browser tab!
