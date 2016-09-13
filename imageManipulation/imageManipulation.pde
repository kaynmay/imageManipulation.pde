PImage img;

void setup(){
  // make surface the size of the photo
  // load image
  surface.setResizable(true); 
  img = loadImage("flowers.JPG");
  surface.setSize(img.width, img.height); 
}

// greyscale filter
void greyScale(PImage img){
  // set width and height to same as image
  img.loadPixels();
  int width = img.width;
  int height = img.height;

  // iterate through each pixel
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      
      // index of where the pixel is in array
      int index = x + y*width;
      
      // set color mode to RGB
      colorMode(RGB);

      // store the rgb values
      float red = red(img.pixels[index]);
      float green = green(img.pixels[index]);
      float blue = blue(img.pixels[index]);
      
      // find the average of the rgb values
      float average = (red + green + blue) / 3;
      average = constrain(average, 0, 255);

      // set rgb values to the average
      img.pixels[index] = color(average, average, average);
    }
  }
  img.updatePixels();
}

// contrast filter
void contrast(PImage img){
  // set width and height to same as image
  img.loadPixels();
  int width = img.width;
  int height = img.height;

  // iterate through each pixel
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      
      // index of where the pixel is in array
      int index = x + y*width;
      
      // choose a threshold 
      int t = 5;
      
      // change color mode to HSB
      colorMode(HSB,100);
      
      // store the hue and saturation values
      float hue = hue(img.pixels[index]);
      float saturation = saturation(img.pixels[index]);

      // find out what the brightness value is
      float newBright = 0;
      float bright = brightness(img.pixels[index]);
      // if brightness is over 50 make it brighter
      if (bright > 50) {
        newBright = bright + t;
      } 
      // if brightness isn't over 50 make it darker
      else{
        newBright = bright - t;
      }
      
      // change brightness on image to the new value
      newBright = constrain(newBright, 0, 100);
      img.pixels[index] = color(hue, saturation, newBright);
  }
  img.updatePixels();
  }
}

// blur filter
void blur(PImage img){
  // set width and height to same as image
  img.loadPixels();
  int width = img.width;
  int height = img.height;
  
  // create convolution matrix
  float[][] matrix = {{.0625, .125, .0625}, {.125, .25, .125}, {.0625, .125, .0625}};
                     
  // create a buffer image
  PImage buffer = createImage(width, height, RGB);
  buffer.loadPixels();
  
  // set color mode to RGB
  colorMode(RGB);

  // iterate through each pixel
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      
      // index of where the pixel is in array
      int index = x + y*width;
      
      // disregard edge pixels
      if (x == 0 || y == 0 || x == width - 1 || y == height - 1) {
        buffer.pixels[index] = color(red(img.pixels[index]), green(img.pixels[index]), blue(img.pixels[index]));
      } 
      
     // go through the convolution matrix for red green and blue
      else {
        float red = 0, green = 0, blue = 0;
        
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int redIndex = (x + i - 1) + img.width*(y + j - 1);
            red += red(img.pixels[redIndex]) * matrix[i][j]; 
          }
        }
            
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int greenIndex = (x + i - 1) + img.width*(y + j - 1);
            green += green(img.pixels[greenIndex]) * matrix[i][j]; 
          }
        }
            
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int blueIndex = (x + i - 1) + img.width*(y + j - 1);
            blue += blue(img.pixels[blueIndex]) * matrix[i][j]; 
          }
        }
        
        // constrain each value    
        red = constrain(red, 0, 255);
        green = constrain(green, 0, 255);
        blue = constrain(blue, 0, 255);
        
        // change the pixels on the buffer
        buffer.pixels[index] = color(red, green, blue);
      }
    }
  }
  // once the entire image is done transfer back to the original image
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      
      int index = x + y*width;
      img.pixels[index] = buffer.pixels[index];
    }
  }
      
  img.updatePixels();
}

// edge detection filter
void edge(PImage img){
  // set width and height to same as image
  img.loadPixels();
  int width = img.width;
  int height = img.height;
  
  // convert the img to greyscale
  greyScale(img);
  
  // create vertical convolution matrix
  float[][] matrix = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
                     
  // create a buffer image
  PImage buffer = createImage(width, height, HSB);
  buffer.loadPixels();
  
  // set color mode to HSB
  colorMode(HSB, 100);

  // iterate through each pixel
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      
      // index of where the pixel is in array
      int index = x + y*width;
      
      // disregard edge pixels
      if (x == 0 || y == 0 || x == width - 1 || y == height - 1) {
        buffer.pixels[index] = color(hue(img.pixels[index]), saturation(img.pixels[index]), brightness(img.pixels[index]));
      } 
      
     // go through the convolution matrix for brightness
      else {
        float bright = 0;
        float hue = hue(img.pixels[index]);
        float saturation = saturation(img.pixels[index]);
        
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int bIndex = (x + i - 1) + img.width*(y + j - 1);
            bright += brightness(img.pixels[bIndex]) * matrix[i][j]; 
          }
        }
        
        // constrain the value    
        bright = constrain(bright, 0, 100);
        
        // change the pixels on the buffer
        buffer.pixels[index] = color(hue, saturation, bright);
      }
    }
  }
  
    // create horizonal convolution matrix
  float[][] matrix2 = {{-2,-1,-2}, {0, 0, 0}, {1, 2, 1}};
                     
  // create a buffer image
  PImage buffer2 = createImage(width, height, HSB);
  buffer2.loadPixels();
  
  // set color mode to HSB
  colorMode(HSB, 100);

  // iterate through each pixel
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      
      // index of where the pixel is in array
      int index = x + y*width;
      
      // disregard edge pixels
      if (x == 0 || y == 0 || x == width - 1 || y == height - 1) {
        buffer2.pixels[index] = color(hue(img.pixels[index]), saturation(img.pixels[index]), brightness(img.pixels[index]));
      } 
      
     // go through the convolution matrix for brightness
      else {
        float bright = 0;
        float hue = hue(img.pixels[index]);
        float saturation = saturation(img.pixels[index]);
        
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int bIndex2 = (x + i - 1) + img.width*(y + j - 1);
            bright += brightness(img.pixels[bIndex2]) * matrix2[i][j]; 
          }
        }
        
        // constrain the value    
        bright = constrain(bright, 0, 100);
        
        // change the pixels on the buffer
        buffer2.pixels[index] = color(hue, saturation, bright);
      }
    }
  }
  // once the entire image is done transfer back to the original image
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      
      // find the magnitude to decide what goes in final image
      int index = x + y*width;
      float bright1 = brightness(buffer.pixels[index]);
      float bright2 = brightness(buffer2.pixels[index]);
      float magnitude = sqrt(pow(bright1,2) + pow(bright2,2));
      img.pixels[index] = color(hue(img.pixels[index]), saturation(img.pixels[index]), magnitude);
    }
  }
      
  img.updatePixels();
}

void draw(){
  // load image to screen
 image(img,0,0);
 
 // press 0 to get original image
 if (keyPressed == true && key == '0'){
   img = loadImage("flowers.JPG");
 }
 
 // press 1 to call the greyscale filter
 if (keyPressed == true && key == '1'){
   img = loadImage("flowers.JPG");
   greyScale(img);
 } 
 
 // press 2 to call the contrast filter
 if (keyPressed == true && key == '2'){
   img = loadImage("flowers.JPG");
   contrast(img);
 } 
 
 // press 3 to call the blur filter
 if (keyPressed == true && key == '3'){
   img = loadImage("flowers.JPG");
   blur(img);
   blur(img);
   blur(img);
 } 
 
 // press 4 to call the edge detection filter
 if (keyPressed == true && key == '4'){
   img = loadImage("flowers.JPG");
   edge(img);
 } 
}