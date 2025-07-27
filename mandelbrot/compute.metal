#include <metal_stdlib>
using namespace metal;

kernel void mandelbrot(texture2d<float, access::write> output [[texture(0)]],
                      uint2 gid [[thread_position_in_grid]],
                      constant float4& params [[buffer(0)]]) {
    float2 dims = float2(output.get_width(), output.get_height());
    float2 uv = float2(gid) / dims;
    
    // Map to complex plane
    float2 c = mix(float2(params.x, params.y), float2(params.z, params.w), uv);
    float2 z = float2(0.0);
    
    int iter = 0;
    for (int i = 0; i < 256; i++) {
        z = float2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
        if (length_squared(z) > 4.0) break;
        iter++;
    }
    
    float3 color = float3(iter / 256.0);
    output.write(float4(color, 1.0), gid);
}
