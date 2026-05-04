# Pexels API Setup Guide

## 🎬 Getting Your Free Pexels API Key

1. **Go to Pexels API**: https://www.pexels.com/api/
2. **Sign up for free** (no credit card required)
3. **Get your API key** from the dashboard
4. **Update the API key** in the code

## 🔧 How to Update the API Key

1. Open `Yapomogayu/viewmodel/PexelsVideoService.swift`
2. Find this line:
   ```swift
   private let apiKey = "YOUR_PEXELS_API_KEY"
   ```
3. Replace `YOUR_PEXELS_API_KEY` with your actual API key:
   ```swift
   private let apiKey = "your_actual_api_key_here"
   ```

## ✅ Benefits of Pexels API

- **Free**: No cost, no credit card required
- **High Quality**: Professional videos
- **No Authentication**: Just an API key
- **Charity Content**: Perfect for your app's purpose
- **Reliable**: Stable API with good documentation

## 🎯 What This Gives You

- **Real charity videos** from Pexels
- **No login required** for users
- **Automatic video rotation** with different charity topics
- **High-quality content** for your app

## 🚀 Ready to Use

Once you add your API key, the app will automatically:
1. Fetch charity-related videos from Pexels
2. Display them in the video feed
3. Allow users to swipe through videos
4. Track video watching for gamification

No more complex TikTok OAuth - just simple, reliable video content!

