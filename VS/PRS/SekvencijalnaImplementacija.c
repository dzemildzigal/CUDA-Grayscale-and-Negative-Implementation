#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

int main(int argc, char const *argv[])
{
	unsigned char i = 1;
	char naziv[6] = "a.jpg\0";
	char izlaz[7] = "ao.jpg\0";
	for (i = 1; i <= 8; i++) {
		naziv[0] = i+48;
		int width, height, channels;
		printf("%s", &naziv);
		unsigned char *img = stbi_load(naziv, &width, &height, &channels, 0);
		if (img == NULL) {
			printf("Greska pri ucitavanju slike.\n");
			exit(1);
		}

		size_t img_size = width * height * channels;
		int gray_channels = channels == 4 ? 2 : 1;
		size_t gray_img_size = width * height * gray_channels;
		unsigned char *gray_img = malloc(gray_img_size);

		if (gray_img == NULL) {
			printf("Nema dovoljno memorije za grayscale sliku.\n");
			exit(1);
		}

		for (unsigned char *p = img, *pg = gray_img; p != img + img_size; p += channels, pg += gray_channels) {
			*pg = (uint8_t)((*p + *(p + 1) + *(p + 2)) / 3.0);
			if (channels == 4) {
				*(pg + 1) = *(p + 3);
			}
		}
		izlaz[0] = naziv[0];
		stbi_write_jpg(izlaz, width, height, gray_channels, gray_img, 100);
	}
	return 0;
}
