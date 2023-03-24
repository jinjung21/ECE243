//include boolean header library for true and false
#include <stdbool.h>
#include <stdlib.h>

//pixel_buffer_start points to the pixel buffer address
volatile int pixel_buffer_start; 

//global variables containing each of the coordinates and increment values for each rectangle;
int x_coords [8];
int y_coords [8];

int inc_x [8];
int inc_y [8];

short int line_colours[10] = {0xFFFF,0x0001,0x07E0, 0x3456, 0xF800, 0x07E0, 0x001F, 0xFFE0, 0xF81F, 0x07FF};

//initiallize functions to be used in main
void plot_pixel(int x1,int y1, short int pixel_colour);
void draw_line(int x1, int y1, int x2, int y2, short int line_colour);
void clear_screen();
void clear_line();
void swap(int * x, int * y);
void wait_state();
void random_initialize(int x_coords [8],int y_coords [8],int inc_x [8],int inc_y [8], short int line_colours [10]);
void draw_rect(int x, int y, int length, int width,short int rect_colour);

//main function loop 
int main(void){

    //keep the program running and prevent the program from ending
    //animate the drawing
    short int colour = 0xFFFF;

    //pointer to the pixel controller address
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;
    
    random_initialize(x_coords, y_coords, inc_x, inc_y, line_colours);

    //draw 4 lines of different colours at following points
    for (int i = 0; i < 8; ++i){

        draw_rect(x_coords[i],y_coords[i],1,1,colour);
        if(i ==7)
            draw_line(x_coords[i], y_coords[i], x_coords[0],y_coords[0], line_colours[i]);
        else
            draw_line(x_coords[i], y_coords[i], x_coords[i+1],y_coords[i+1], line_colours[i]);
    }

    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the back buffer

    /* now, swap the front/back buffers, to set the front buffer location */
    wait_state();
    
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    
    while(true){
        clear_screen();

    //draw 4 lines of different colours at following points
    for (int i = 0; i < 8; ++i){

        draw_rect(x_coords[i],y_coords[i],2,2,colour);
        if(i ==7)
            draw_line(x_coords[i], y_coords[i], x_coords[0],y_coords[0], line_colours[i]);
        else
            draw_line(x_coords[i], y_coords[i], x_coords[i+1],y_coords[i+1], line_colours[i]);
    }

    for (int i = 0; i < 8; ++i){
        if(x_coords[i] == 319)
            inc_x[i] = -1;
        if(x_coords[i] == 0)
            inc_x[i] = 1;
        if(y_coords[i] == 239)
            inc_y[i] = -1;
        if(y_coords[i] == 0)
            inc_y[i] = 1;

        x_coords[i] = x_coords[i] + inc_x[i];
        y_coords[i] = y_coords[i] + inc_y[i];
        }
        wait_state(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer

    }

    return 0;
}
void random_initialize(int x_coords [8],int y_coords [8],int inc_x [8],int inc_y [8], short int line_colours [10]){

    for(int i = 0; i < 8; ++i){
        
        x_coords[i] = rand() % (319 + 1 + 0) - 0;
        y_coords[i] = rand() % (239 + 1 + 0) - 0;
        inc_x[i] = rand() % 2 * 2 - 1;
        inc_y[i] = rand() % 2 * 2 - 1;
        line_colours[i] = line_colours[rand() %10];                 
    }
    

}

//draw a rectangle at a point with specified width and length
void draw_rect(int x, int y, int length, int width,short int rect_colour){

    for(int i = 0; i < length; ++i){
        for(int j = 0; j < width; ++j){
            plot_pixel(x,y, rect_colour);
            x +=1; 
        }
        y+=1;
    }
}

void clear_line(int x1, int y1, int x2, int y2){
    draw_line(x1, y1, x2, y2, 0x000);
}

void wait_state(){
    //set the pixel_ctrl_ptr to point to the pixel_ctrl_ptr address
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;

    //status points to the status register to check for synchronization
    volatile int * status =(int *)0xFF20302C;

    *pixel_ctrl_ptr = 1;

    //if the value at status is 1, keep reading. exit once synchronized
    while((*status & 0x01) != 0) 
        status = status; //keep reading status
    
    //return out of wait_state when s = 1
    return;
}    

//draw_line function, draws a line between 2 points in the specified pixel colour
void draw_line(int x1, int y1, int x2, int y2, short int line_colour){
    
    //initialize is_steep to false
    int is_steep = false; 
    int abs_y = y2 - y1; 
    int abs_x = x2 - x1;
    
    if (abs_y < 0 ) abs_y =-abs_y; //change sign if negative
    if (abs_x < 0) abs_x = -abs_x;
    
    if (abs_y > abs_x) is_steep=1; //TRUE
    
    //swap x and y point if the line is steep
    if (is_steep) {
        swap(&x1, &y1);
        swap(&x2, &y2);
    }
   
    //if point 2 is before point 1, swap the x and y values to allow draw from left to right
    if (x1>x2) {
        swap(&x1, &x2);
        swap(&y1, &y2);
    }
    
    //initialize delta_x and y values
    int delta_x = x2 - x1;
    int delta_y = y2 - y1;
    
    //cant have negative value for delta y, set it to positive, same as using abs()
    if (delta_y <0) 
        delta_y = -delta_y;
    
    
    int error = -(delta_x / 2);
    int draw_y = y1;
    int y_step;
        
    // change the step value according to which y value is bigger
    if (y1 < y2)
        y_step = 1;
    else 
        y_step = -1;
    
    //bresenhams algorithm loop
    for(int draw_x=x1; draw_x <= x2; draw_x++) {
        if (is_steep == true)
            plot_pixel(draw_y,draw_x, line_colour);
        else 
            plot_pixel(draw_x,draw_y, line_colour);
        
        error += delta_y;
        
        if (error>=0) {
            draw_y += y_step;
            error -= delta_x;
        }
    } 

}

void clear_screen(){

    //initialize variables to iterate through the pixels
    int x;
	int y;
	
    //go over each pixel in the vga display and set the colour of the pixel to black
    for (x = 0; x < 320; x++)
		for (y = 0; y < 240; y++)
			plot_pixel(x, y, 0x0000);	

}

//Function that plots a pixel on the VGA Display
void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

//helper function to switch 2 variable values with eachother 
void swap(int * x, int * y){
	int temp = *x;
    *x = *y;
    *y = temp;   
}