
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <device_launch_parameters.h>
#include <time.h>
#define STB_IMAGE_IMPLEMENTATION
#include "C://Users/Jemo/source/repos/Paralelna implementacija/Paralelna implementacija/stb_image/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "C://Users/Jemo/source/repos/Paralelna implementacija/Paralelna implementacija/stb_image/stb_image_write.h"
void getError(cudaError_t err) {
	if (err != cudaSuccess) {
		printf("Greska");
	}
}

__global__
void grayscale(const unsigned char* input_rgb, unsigned char* input_gray,const int width, const int height) {
	const unsigned int offset = blockIdx.x*blockDim.x + threadIdx.x;
	if (offset >= width * height) return;
	const unsigned int a = (offset << 1) + (offset); //a = offset*3
		input_gray[offset] = (input_rgb[a] + input_rgb[a + 1] + input_rgb[a + 2]) * .33333333333333;
}

__global__
void negative(const unsigned char* input_rgb,unsigned char* output, const int width, const int height) {
	const unsigned int offset = blockIdx.x*blockDim.x + threadIdx.x;
	if (offset >= width * height) return;
	const unsigned int a = (offset << 1) + (offset); // a = offset*3
	output[a] = 255 - input_rgb[a];
	output[a + 1] = 255 - input_rgb[a+1];
	output[a + 2] = 255 - input_rgb[a+2];
}

	

int main(void) { 
	unsigned char i = 1;
	double time = 0.0;
	char naziv[6] = "a.jpg"; 
	naziv[5] = '\0';
	char izlaz[7] = "ao.jpg"; 
	izlaz[6] = '\0';
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	unsigned char *input, *output;
	for (i = 1; i <= 8; ++i) {
		naziv[0] = i + 48;

		int width, height, channels;

		input= stbi_load(naziv, &width, &height, &channels, 0);
		size_t img_size = width * height * channels;
		int gray_channels = channels == 4 ? 2 : 1;
		size_t gray_img_size = width * height * gray_channels;
		unsigned char *gray_img = (unsigned char*)malloc(gray_img_size);
		unsigned char *dev_input_RGB, *dev_input_GRAY, *dev_input_RGB_2;
		
		getError(cudaMalloc((void**)&dev_input_RGB, img_size * sizeof(unsigned char)));
		getError(cudaMemcpy(dev_input_RGB, input, img_size * sizeof(unsigned char), cudaMemcpyHostToDevice));

		getError(cudaMalloc((void**)&dev_input_RGB_2, img_size * sizeof(unsigned char)));
		getError(cudaMemcpy(dev_input_RGB_2, input, img_size * sizeof(unsigned char), cudaMemcpyHostToDevice));

		getError(cudaMalloc((void**)&dev_input_GRAY, gray_img_size * sizeof(unsigned char)));
		getError(cudaMemcpy(dev_input_GRAY, gray_img, gray_img_size * sizeof(unsigned char), cudaMemcpyHostToDevice));



		dim3 blockDims(640, 1, 1);
		dim3 gridDims((unsigned int)ceil((double)(width*height / (blockDims.x))), 1, 1);
		//dim3 blockDims(32, 32, 1);
		//dim3 gridDims(1 + (width / 32), 1 + (height / 32), 1);


		cudaEventRecord(start);
		 // pozvati kernel ovdje
		grayscale <<<gridDims, blockDims >>> (dev_input_RGB,dev_input_GRAY, width, height);
		//negative << <gridDims, blockDims >> > (dev_input_RGB, dev_input_RGB_2, width, height);
		//negative << <numBlocks, threadsPerBlock >> > (dev_input_RGB, dev_input_RGB_2, width, height);
		cudaEventRecord(stop);
		cudaEventSynchronize(stop);
		float milis = 0;
		cudaEventElapsedTime(&milis, start, stop);
		time += milis;


		getError(cudaMemcpy(gray_img, dev_input_GRAY, gray_img_size * sizeof(unsigned char), cudaMemcpyDeviceToHost));
		//getError(cudaMemcpy(input,dev_input_RGB_2, img_size * sizeof(unsigned char), cudaMemcpyDeviceToHost));
		getError(cudaFree(dev_input_GRAY));
		getError(cudaFree(dev_input_RGB));
		//getError(cudaFree(dev_input_RGB_2));
		izlaz[0] = naziv[0];
		stbi_write_jpg(izlaz, width, height, 1, gray_img, 100);
		//stbi_write_jpg(izlaz, width, height, 3, input,100);
	}
	printf("ukupno %f ms \n", time);
	return 0; 
}