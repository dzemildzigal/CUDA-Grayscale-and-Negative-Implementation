#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image/stb_image_write.h"

int main(int argc, char const *argv[])
{
int width, height, channels;
unsigned char *img = stbi_load("flower.jpg", &width, &height, &channels, 0);
    if(img == NULL) {
        printf("Greska pri ucitavanju slike.\n");
        exit(1);
    }

size_t img_size = width * height * channels;
int gray_channels = channels == 4 ? 2 : 1;
size_t gray_img_size = width * height * gray_channels;
unsigned char *gray_img = malloc(gray_img_size);

    if(gray_img == NULL) {
        printf("Nema dovoljno memorije za grayscale sliku.\n");
        exit(1);
    }

    for(unsigned char *p = img, *pg = gray_img; p != img + img_size; p += channels, pg += gray_channels) {
    *pg = (uint8_t)((*p + *(p + 1) + *(p + 2))/3.0);
        if(channels == 4) {
            *(pg + 1) = *(p + 3);
        }
    }
stbi_write_jpg("flower.jpg", width, height, gray_channels, gray_img, 100);

return 0;
}
