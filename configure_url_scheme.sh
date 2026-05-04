#!/bin/bash

# Script to configure URL scheme for TikTok OAuth
echo "🔧 Configuring URL scheme for TikTok OAuth..."

# Open Xcode project
echo "📱 Opening Xcode project..."
open /Users/armanshavelian/Desktop/YapomogayuV2/Yapomogayu.xcodeproj

echo ""
echo "✅ Xcode project opened!"
echo ""
echo "📋 Manual steps to configure URL scheme:"
echo "1. In Xcode, select your project (blue icon at top)"
echo "2. Select the 'YapomogayuV2' target"
echo "3. Go to the 'Info' tab"
echo "4. Scroll down to 'URL Types' section"
echo "5. Click the '+' button to add a new URL Type"
echo "6. Fill in:"
echo "   - Identifier: yapomogayu.tiktok.auth"
echo "   - URL Schemes: yapomogayu"
echo "   - Role: Editor (default)"
echo "7. Click 'Done'"
echo ""
echo "🎯 This will allow TikTok to redirect back to your app after OAuth!"
echo ""
echo "After configuring, try building and running the app again."

