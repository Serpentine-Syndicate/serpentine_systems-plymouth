// Animation parameters
float time = 0;
float baseSpeed = 0.025;  // Matched with static animation
// Calculate loop duration based on text rotation
// We want the text to make a complete rotation and return to its starting position
float loopDuration = TWO_PI;  // One complete rotation
float[] radii = {50, 70, 90};  // Restored to original sizes
// Adjust speed multipliers to be rational numbers that complete their cycles within the text loop
float[] speedMultipliers = {-4.0, 3.0, -2.0};  // Speeds that divide evenly into text rotation
int numDots = 16;  // Number of dots per ring
float dotSize = 4;  // Restored to original size
String text = "SERPENTINESYSTEMS";  // Uppercase for simpler pixel patterns
float textRadius = 110;  // Restored to original size
float textSpeedMultiplier = 1.0;  // Simplified to make loop calculation easier

// Pixel data for characters (9x9 grid)
int[][][] letters = new int[128][9][9];  // ASCII characters

// Frame export parameters
boolean isExporting = false;
boolean hasCompletedLoop = false;

void setup() {
  size(240, 240);  // Removed P2D, using default renderer
  noSmooth();  // Disable anti-aliasing
  frameRate(15);  // Matched with static animation
  initLetters();  // Initialize letter patterns
  pixelDensity(1);  // Force 1:1 pixel density
}

void initLetters() {
  // S
  letters['S'] = new int[][] {
    {0,1,1,1,1,1,1,1,0},
    {1,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0},
    {0,1,1,1,1,1,1,1,0},
    {0,0,0,0,0,0,0,0,1},
    {0,0,0,0,0,0,0,0,1},
    {0,0,0,0,0,0,0,0,1},
    {0,1,1,1,1,1,1,1,0}
  };
  // E
  letters['E'] = new int[][] {
    {1,1,1,1,1,1,1,1,1},
    {1,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0},
    {1,1,1,1,1,1,0,0,0},
    {1,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0},
    {1,1,1,1,1,1,1,1,1}
  };
  // R
  letters['R'] = new int[][] {
    {1,1,1,1,1,1,1,0,0},
    {1,0,0,0,0,0,0,1,0},
    {1,0,0,0,0,0,0,1,0},
    {1,0,0,0,0,0,0,1,0},
    {1,1,1,1,1,1,1,0,0},
    {1,0,0,0,1,0,0,0,0},
    {1,0,0,0,0,1,0,0,0},
    {1,0,0,0,0,0,1,0,0},
    {1,0,0,0,0,0,0,1,0}
  };
  // P
  letters['P'] = new int[][] {
    {1,1,1,1,1,1,1,0,0},
    {1,0,0,0,0,0,0,1,0},
    {1,0,0,0,0,0,0,1,0},
    {1,0,0,0,0,0,0,1,0},
    {1,1,1,1,1,1,1,0,0},
    {1,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0}
  };
  // N
  letters['N'] = new int[][] {
    {1,0,0,0,0,0,0,0,1},
    {1,1,0,0,0,0,0,0,1},
    {1,0,1,0,0,0,0,0,1},
    {1,0,0,1,0,0,0,0,1},
    {1,0,0,0,1,0,0,0,1},
    {1,0,0,0,0,1,0,0,1},
    {1,0,0,0,0,0,1,0,1},
    {1,0,0,0,0,0,0,1,1},
    {1,0,0,0,0,0,0,0,1}
  };
  // T
  letters['T'] = new int[][] {
    {1,1,1,1,1,1,1,1,1},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0}
  };
  // I
  letters['I'] = new int[][] {
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0}
  };
  // Y
  letters['Y'] = new int[][] {
    {1,0,0,0,0,0,0,0,1},
    {0,1,0,0,0,0,0,1,0},
    {0,0,1,0,0,0,1,0,0},
    {0,0,0,1,0,1,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0}
  };
  // M
  letters['M'] = new int[][] {
    {1,0,0,0,0,0,0,0,1},
    {1,1,0,0,0,0,0,1,1},
    {1,0,1,0,0,0,1,0,1},
    {1,0,0,1,0,1,0,0,1},
    {1,0,0,0,1,0,0,0,1},
    {1,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,1}
  };
  // Space
  letters[' '] = new int[][] {
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0}
  };
}

void drawPixelChar(char c, float x, float y, float size) {
  if (letters[c] == null) return;
  
  float pixelSize = size/9;  // Now divided by 9 instead of 10
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (letters[c][j][i] == 1) {
        rect(x + i*pixelSize, y + j*pixelSize, pixelSize, pixelSize);
      }
    }
  }
}

void draw() {
  background(0);  // Black background
  loadPixels();  // Ensure pixel-perfect rendering
  
  // Center everything without scaling
  translate(width/2, height/2);
  
  // Draw rings
  noStroke();
  fill(255);
  
  // Draw each ring
  for (int i = 0; i < 3; i++) {
    float rotation = time * baseSpeed * speedMultipliers[i];
    
    // Draw dots for this ring
    for (int j = 0; j < numDots; j++) {
      float angle = j * (TWO_PI/numDots) + rotation;
      float x = cos(angle) * radii[i];
      float y = sin(angle) * radii[i];
      
      circle(x, y, dotSize);
    }
  }
  
  // Draw rotating text
  noStroke();
  fill(255);
  pushMatrix();
  float textRotation = (time * baseSpeed * textSpeedMultiplier) % TWO_PI;
  rotate(textRotation);
  
  // Draw each character
  for (int i = 0; i < text.length(); i++) {
    float angle = -i * TWO_PI / text.length();
    pushMatrix();
    rotate(angle + PI/2);
    translate(textRadius, -1);
    rotate(-PI/2);
    drawPixelChar(text.charAt(i), 0, 0, 9);  // Scaled down character size
    popMatrix();
  }
  popMatrix();
  
  // Update time and handle frame export
  if (isExporting) {
    time += 1;
    float fullLoop = loopDuration / baseSpeed;
    
    // Save the current frame
    saveFrame("../plymouth/progress-" + nf(frameCount-1, 0) + ".png");  // Save to plymouth folder
    println("Saving frame " + (frameCount-1));
    
    // Check if we've completed a loop
    if (time >= fullLoop && !hasCompletedLoop) {
      println("Loop complete! Total frames: " + (frameCount-1));
      hasCompletedLoop = true;
      exit();
    }
  } else {
    // For preview, use regular timing
    time += 1;
    float fullLoop = loopDuration / baseSpeed;
    if (time >= fullLoop) {
      time = time % fullLoop;
    }
  }
} 