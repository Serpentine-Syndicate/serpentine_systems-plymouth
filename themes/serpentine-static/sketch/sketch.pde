// Animation parameters
float time = 0;
float baseSpeed = 0.005;  // Base speed for all rotations
float loopDuration = TWO_PI;  // One complete rotation
float staticRadius = 70;  // Slightly smaller radius for the static circle
String text = "SERPENTINESYSTEMS";  // Uppercase for simpler pixel patterns
float textRadius = 110;  // Text ring radius
float textSpeedMultiplier = 1.0;  // Text rotation speed
float noiseScale = 0.2;  // Scale of the noise pattern

// Pixel data for characters (9x9 grid)
int[][][] letters = new int[128][9][9];  // ASCII characters

// Frame export parameters
boolean isExporting = false;
boolean hasCompletedLoop = false;

void setup() {
  size(240, 240);  // Back to original size
  noSmooth();  // Disable anti-aliasing
  frameRate(30);
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
  background(0);
  
  // Center everything
  translate(width/2, height/2);
  
  // Draw static filled circle
  loadPixels();
  
  // Generate static points filling the circle
  for (int x = -int(staticRadius); x <= staticRadius; x++) {
    for (int y = -int(staticRadius); y <= staticRadius; y++) {
      // Check if point is inside circle
      if (x*x + y*y <= staticRadius*staticRadius) {
        // Calculate screen position
        int screenX = width/2 + x;
        int screenY = height/2 + y;
        
        if (screenX >= 0 && screenX < width && screenY >= 0 && screenY < height) {
          // Use noise for organic flow, based on position and time
          float noiseVal = noise((x + width/2) * noiseScale + time * baseSpeed * 5, 
                               (y + height/2) * noiseScale + time * baseSpeed * 5);
          
          int loc = screenX + screenY * width;
          pixels[loc] = (noiseVal > 0.5) ? color(255) : color(0);
        }
      }
    }
  }
  updatePixels();
  
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
    drawPixelChar(text.charAt(i), 0, 0, 9);
    popMatrix();
  }
  popMatrix();
  
  // Update time and handle frame export
  if (isExporting) {
    time += 1;
    float fullLoop = loopDuration / baseSpeed;
    
    // Save the current frame
    saveFrame("../plymouth/progress-" + nf(frameCount-1, 0) + ".png");
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