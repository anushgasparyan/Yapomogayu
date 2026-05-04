#!/bin/bash

echo "🧪 Testing URL scheme configuration..."

# Test if the URL scheme is registered
echo "📱 Testing URL scheme: yapomogayu://tiktok-auth?code=test123"

# Try to open the URL scheme
open "yapomogayu://tiktok-auth?code=test123"

echo "✅ If your app opens, the URL scheme is working!"
echo "❌ If nothing happens, the URL scheme is not configured properly."
echo ""
echo "🔧 To fix:"
echo "1. Make sure you added the URL scheme in Xcode"
echo "2. Build and install the app on simulator/device"
echo "3. Try this test again"

