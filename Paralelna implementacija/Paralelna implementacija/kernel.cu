
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size);

__global__ 
void grayScale(const uchar4* rgbImage, unsigned char* grayscaleImage, const int height, const int width) {
	int x = blockDim.x * blockDim.x + threadIdx.x; // dobijanje x koordinate piksela
	int y = blockDim.y * blockDim.y + threadIdx.y; // dobijanje y koordinate piksela
	if (x >= width || y >= height) return; // pregled da li je vrijednost proslijedjena funkciji unutar slike
	int pixelIndex = width * y + x;
	grayscaleImage[pixelIndex] = 0.299f * rgbImage[pixelIndex].x + 0.587f * rgbImage[pixelIndex].y + 0.114f * rgbImage[pixelIndex].z;
}


int main()
{
	uchar4 *rgbimg=0;
	unsigned char *grayimg=0;
	int width=0, height=0, channels = 0;
	const int BLOCK_SZ = 128;
	const dim3 blockSz(BLOCK_SZ, BLOCK_SZ, 1);
	const dim3 gridSz(width / BLOCK_SZ + 1, height / BLOCK_SZ + 1, 1);
	grayScale <<<gridSz, blockSz >>> (rgbimg, grayimg, height, width);
	printf("Hello world");
    return 0;
}
