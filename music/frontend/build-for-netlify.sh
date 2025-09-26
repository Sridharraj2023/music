#!/bin/bash

# Build script for Netlify deployment
echo "🚀 Building React Admin Frontend for Netlify..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Set production environment variable if not set
if [ -z "$VITE_API_URL" ]; then
    echo "⚠️  VITE_API_URL not set. Using default backend URL."
    echo "Please set VITE_API_URL environment variable in Netlify dashboard."
fi

# Build the project
echo "🔨 Building project..."
npm run build

# Check if build was successful
if [ -d "dist" ]; then
    echo "✅ Build successful! Dist folder created."
    echo "📁 Contents of dist folder:"
    ls -la dist/
else
    echo "❌ Build failed! Check the error messages above."
    exit 1
fi

echo "🎉 Ready for Netlify deployment!"
echo "📋 Next steps:"
echo "1. Connect your GitHub repository to Netlify"
echo "2. Set base directory to: music/frontend"
echo "3. Set build command to: npm run build"
echo "4. Set publish directory to: music/frontend/dist"
echo "5. Add environment variable VITE_API_URL with your backend URL"
