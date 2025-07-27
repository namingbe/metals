# Compile shader
xcrun -sdk macosx metal -c compute.metal -o compute.air
xcrun -sdk macosx metallib compute.air -o compute.metallib

# Compile and link
clang++ -std=c++17 -framework Metal -framework Foundation -framework CoreGraphics -framework ImageIO main.mm -o mandelbrot

# Run
./mandelbrot

