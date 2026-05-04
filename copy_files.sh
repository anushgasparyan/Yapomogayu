#!/bin/bash

# 🚀 YapomogayuV2 Transfer Script
# This script helps copy all necessary files to a new project

echo "🚀 Starting YapomogayuV2 Transfer Process..."

# Check if destination directory is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide destination directory"
    echo "Usage: ./copy_files.sh /path/to/new/project"
    exit 1
fi

DEST_DIR="$1"
SOURCE_DIR="/Users/armanshavelian/Desktop/YapomogayuV2/Yapomogayu"

echo "📁 Source: $SOURCE_DIR"
echo "📁 Destination: $DEST_DIR"

# Create destination directories if they don't exist
mkdir -p "$DEST_DIR/Models"
mkdir -p "$DEST_DIR/Views"
mkdir -p "$DEST_DIR/ViewModels"
mkdir -p "$DEST_DIR/Assets.xcassets"

echo "📋 Copying Swift files..."

# Copy model files
echo "  📄 Copying Models..."
cp "$SOURCE_DIR/model/"*.swift "$DEST_DIR/Models/" 2>/dev/null || echo "  ⚠️  No model files found"

# Copy view files
echo "  📄 Copying Views..."
cp "$SOURCE_DIR/view/"*.swift "$DEST_DIR/Views/" 2>/dev/null || echo "  ⚠️  No view files found"

# Copy viewmodel files
echo "  📄 Copying ViewModels..."
cp "$SOURCE_DIR/viewmodel/"*.swift "$DEST_DIR/ViewModels/" 2>/dev/null || echo "  ⚠️  No viewmodel files found"

# Copy main app file
echo "  📄 Copying main app file..."
cp "$SOURCE_DIR/YapomogayuApp.swift" "$DEST_DIR/" 2>/dev/null || echo "  ⚠️  Main app file not found"

# Copy assets
echo "  🎨 Copying Assets..."
cp -r "$SOURCE_DIR/Assets.xcassets/"* "$DEST_DIR/Assets.xcassets/" 2>/dev/null || echo "  ⚠️  Assets not found"

echo ""
echo "✅ Transfer completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open your new project in Xcode"
echo "2. Add SwiftUIPager dependency: https://github.com/fermoya/SwiftUIPager"
echo "3. Add the copied files to your Xcode project"
echo "4. Update bundle identifier and app name"
echo "5. Test the build"
echo ""
echo "📖 See TRANSFER_GUIDE.md for detailed instructions"

