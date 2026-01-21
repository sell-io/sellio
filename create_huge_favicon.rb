#!/usr/bin/env ruby
# Script to help create a huge favicon
# This script provides instructions for creating a favicon where the icon fills the entire canvas

puts "=" * 60
puts "CREATING A HUGE FAVICON"
puts "=" * 60
puts
puts "To make the favicon appear HUGE in browser tabs:"
puts
puts "1. The icon content must fill 95-98% of the image canvas"
puts "2. Use minimal padding (1-2% maximum)"
puts "3. The icon should go almost edge-to-edge"
puts
puts "RECOMMENDED STEPS:"
puts "-" * 60
puts "1. Open your original icon/logo file"
puts "2. Crop it so the icon fills 95-98% of the frame"
puts "3. Resize to 64x64 pixels (or 96x96 for even better quality)"
puts "4. Save as PNG with transparency"
puts "5. Replace public/TabIcon.png"
puts
puts "ONLINE TOOL (EASIEST):"
puts "-" * 60
puts "1. Go to: https://realfavicongenerator.net/"
puts "2. Upload your icon"
puts "3. Set 'Padding' to 0% or 1%"
puts "4. Download and replace public/TabIcon.png"
puts
puts "The key: Icon must fill 95-98% of canvas, NOT be centered with padding!"
puts "=" * 60
