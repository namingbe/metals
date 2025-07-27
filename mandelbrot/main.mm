#import <Metal/Metal.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#include <simd/simd.h>

int main() {
    @autoreleasepool {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        id<MTLCommandQueue> queue = [device newCommandQueue];
        
        // Load shader
        NSError* error = nil;
        NSURL* libURL = [NSURL fileURLWithPath:@"compute.metallib"];
        id<MTLLibrary> lib = [device newLibraryWithURL:libURL error:&error];
        if (error) NSLog(@"Library error: %@", error);
        
        id<MTLFunction> kernel = [lib newFunctionWithName:@"mandelbrot"];
        id<MTLComputePipelineState> pipeline = [device newComputePipelineStateWithFunction:kernel error:&error];
        
        // Create texture
        MTLTextureDescriptor* texDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                           width:1024
                                                                                          height:1024
                                                                                       mipmapped:NO];
        texDesc.usage = MTLTextureUsageShaderWrite;
        id<MTLTexture> texture = [device newTextureWithDescriptor:texDesc];
        
        // Set params
        simd_float4 params = {-2.0f, -1.5f, 1.0f, 1.5f};
        
        // Encode and run
        id<MTLCommandBuffer> cmdBuffer = [queue commandBuffer];
        id<MTLComputeCommandEncoder> encoder = [cmdBuffer computeCommandEncoder];
        
        [encoder setComputePipelineState:pipeline];
        [encoder setTexture:texture atIndex:0];
        [encoder setBytes:&params length:sizeof(params) atIndex:0];
        
        MTLSize gridSize = MTLSizeMake(1024, 1024, 1);
        MTLSize threadgroupSize = MTLSizeMake(16, 16, 1);
        
        [encoder dispatchThreads:gridSize threadsPerThreadgroup:threadgroupSize];
        [encoder endEncoding];
        
        [cmdBuffer commit];
        [cmdBuffer waitUntilCompleted];
        
        // Get texture data
        uint8_t* imageData = (uint8_t*)malloc(1024 * 1024 * 4);
        [texture getBytes:imageData bytesPerRow:1024*4 fromRegion:MTLRegionMake2D(0, 0, 1024, 1024) mipmapLevel:0];
        
        // Create CGImage and save
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(imageData, 1024, 1024, 8, 1024*4, colorSpace, kCGImageAlphaPremultipliedLast);
        CGImageRef image = CGBitmapContextCreateImage(context);
        
        NSURL* url = [NSURL fileURLWithPath:@"mandelbrot.png"];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)url, CFSTR("public.png"), 1, NULL);
        CGImageDestinationAddImage(destination, image, NULL);
        CGImageDestinationFinalize(destination);
        
        free(imageData);
        CGImageRelease(image);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        CFRelease(destination);
        
        NSLog(@"Saved mandelbrot.png");
    }
    return 0;
}
