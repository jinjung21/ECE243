/* This files provides address values that exist in the system */

#define SDRAM_BASE            0xC0000000
#define FPGA_ONCHIP_BASE      0xC8000000
#define FPGA_CHAR_BASE        0xC9000000

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define TIMER_BASE            0xFF202000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030

/* VGA colors */
#define WHITE 0xFFFF
#define YELLOW 0xFFE0
#define RED 0xF800
#define GREEN 0x07E0
#define BLUE 0x001F
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define GREY 0xC618
#define PINK 0xFC18
#define ORANGE 0xFC00

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240

/* Constants for animation */
#define BOX_LEN 2
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

// Begin part1.s for Lab 7

volatile int pixel_buffer_start; // global variable

void clear_screen();
void draw_line(int x0, int y0, int x1, int y1, short int color);
void plot_pixel(int x, int y, short int line_color);
void swap(int* p1, int* p2);
void wait_for_vsync();

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
    int x1 = 0; 
	int y1 = 150;
    int x2 = 319; 
	int y2 = 150;
    int y_dir = 1;
    
    while (1){
        draw_line(x1, y1, x2, y2, 0xFFFF);
        wait_for_vsync();
        draw_line(x1, y1, x2, y2, 0x0000);

        if (y1 == 0){
            y_dir *= -1;
        }
        else if (y2 == 239){
            y_dir *= -1;
        }

        y1 += y_dir;
        y2 += y_dir;
    }

    return 0;
}

// code not shown for clear_screen() and draw_line() subroutines

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}


void clear_screen(){
    int x,y;
    for (x = 0; x < 320; ++x){
        for (y = 0; y < 240; ++y){
            plot_pixel(x, y, 0x0000);
        }
    }
}

void draw_line(int x1, int y1, int x2, int y2, short int color){
    bool is_steep = 0;

    int abs_x = x2 - x1;
    int abs_y = y2 - y1;

    if (abs_x < 0){
        abs_x *= -1;
    }

    if (abs_y < 0){
        abs_y *= -1;
    }

    is_steep = abs_y > abs_x;

    if (is_steep){
        swap(&x1, &y1);
        swap(&x2, &y2);
    }

    if (x1 > x2){
        swap(&x1, &x2);
        swap(&y1, &y2);
    }

    int deltax = x2 - x1;
    int deltay = y2 - y1;

    if (deltay < 0){
        deltay *= -1;
    }

    int error = -(deltax/2);
    int y = y1;
    int y_step = -1;

    if (y1 < y2){
        y_step = 1;
    }

    int x = x1;

    for (x = x1; x <= x2; ++x){
        if (is_steep){
            plot_pixel(y, x, color);
        }
        else{
            plot_pixel(x, y, color);
        }

        error += deltay;

        if (error >= 0){
            y += y_step;
            error -= deltax;
        }
    }
}

void swap(int* p1, int* p2)
{
	int temp = *p1;
	*p1 = *p2;
	*p2 = temp;
}

void wait_for_vsync(){
    volatile int*pixel_ctrl_ptr = (int*)0xFF203020;
    volatile int*status = (int*)0xFF20302C;

    *pixel_ctrl_ptr = 1;

    while((*status & 0x01) != 0){
        status = status;
    }
    return;
}
