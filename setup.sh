 #!/bin/bash
set -e

echo "Checking Metal development environment..."

# Check if xcrun works
if ! xcrun --version &> /dev/null; then
    echo "Error: xcrun not found. Please install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi

# Check if Metal compiler is available
if ! xcrun -sdk macosx metal --version &> /dev/null; then
    echo "Error: Metal compiler not found."
    echo "Try running: xcode-select -r"
    echo "Or reinstall Xcode Command Line Tools"
    exit 1
fi

echo "✓ Metal development environment is ready!"
echo ""
echo "To compile Metal shaders:"
echo "  xcrun -sdk macosx metal -c shader.metal -o shader.air"
echo "  xcrun -sdk macosx metallib shader.air -o shader.metallib"
echo ""
echo "To compile Objective-C++ with Metal:"
echo "  clang++ -std=c++17 -framework Metal -framework Foundation main.mm -o program"
