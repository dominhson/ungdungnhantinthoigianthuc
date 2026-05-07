#!/bin/bash

# Script to export all PlantUML diagrams to multiple formats
# Usage: ./export_diagrams.sh

echo "🚀 Starting PlantUML diagram export..."

# Create export directories
mkdir -p ../exports/png
mkdir -p ../exports/svg
mkdir -p ../exports/pdf

# Check if plantuml is installed
if ! command -v plantuml &> /dev/null
then
    echo "❌ PlantUML is not installed!"
    echo ""
    echo "Install PlantUML:"
    echo "  macOS:    brew install plantuml"
    echo "  Ubuntu:   sudo apt-get install plantuml"
    echo "  Windows:  choco install plantuml"
    echo ""
    exit 1
fi

# Export to PNG
echo "📸 Exporting to PNG..."
plantuml -tpng *.puml -o ../exports/png/
if [ $? -eq 0 ]; then
    echo "✅ PNG export completed!"
else
    echo "❌ PNG export failed!"
fi

# Export to SVG
echo "🎨 Exporting to SVG..."
plantuml -tsvg *.puml -o ../exports/svg/
if [ $? -eq 0 ]; then
    echo "✅ SVG export completed!"
else
    echo "❌ SVG export failed!"
fi

# Export to PDF (requires additional dependencies)
echo "📄 Exporting to PDF..."
plantuml -tpdf *.puml -o ../exports/pdf/
if [ $? -eq 0 ]; then
    echo "✅ PDF export completed!"
else
    echo "⚠️  PDF export failed (may require additional dependencies)"
fi

echo ""
echo "🎉 Export completed!"
echo "📁 Files saved to: docs/exports/"
echo ""
echo "Generated files:"
ls -lh ../exports/png/*.png 2>/dev/null | awk '{print "  PNG: " $9 " (" $5 ")"}'
ls -lh ../exports/svg/*.svg 2>/dev/null | awk '{print "  SVG: " $9 " (" $5 ")"}'
ls -lh ../exports/pdf/*.pdf 2>/dev/null | awk '{print "  PDF: " $9 " (" $5 ")"}'
