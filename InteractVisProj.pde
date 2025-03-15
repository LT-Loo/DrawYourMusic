/*********************************************************************************
   32027 Interactive Media - 3B Individual Project
   Ler Theng Loo (25076439)
   ------------------------------------------------------------------
   This program turns drawing into music.
   ------------------------------------------------------------------
   Live accumulate inputs - Mouse click & mouse drag (Track cursor's movement)
   Input feedback - Drawing lines (Visual feedback)
   Input interaction - Line colour & thickness manipulation (Colour picker & weight slider)
   Data transformation (Output) - Music notes (Audio)
   Output interaction - Audio speed (Slider / Hand movement on left side of cam screen)
                      - Volume (Slider / Hand movement on right side of cam screen)
                      - Line transparency (MouseY within drawing board)
**********************************************************************************/

// Import Library
import controlP5.*;
import processing.sound.*;

import processing.javafx.*;

import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PImage;
import processing.video.Capture;


/* ----- Global Variables ----- */
// Draw Variables
ArrayList<Line> lines; // List to store lines
Line line; // Variable to store current drawing line
boolean newLine = true; 
int clr; // Color
float lineW; // Line Weight

// Audio Variables
PVector[] levels; // Drawing board is divided into several levels assigned with different notes
TriOsc triOsc; // Triangle Oscillator
Env env; // Envelope for ADSR effect

//int duration = 200; 
float trigger = millis(); // Determine when to play next note
int tempo = 50; // Audio speed
int volume = 5;
int count = -1; // Counter to play notes in order
boolean play = false;

// GUI Variables
ControlP5 cp5;
MyColorPicker cp;
Slider lineWeight;

// Webcam Variables
Capture cam;
PImage inputImage;

DeepVision deepVision = new DeepVision(this);
YOLONetwork yolo;
ResultList<ObjectDetectionResult> detections; // To detect hands


/* ----- GUI Interactive Functions ----- */
// Slider to change thickness of line
void lineWeight(float value) {lineW = value;}

// PLAY button to play notes and start webcam
void Play() {
  play = true;
  cam.start();
  count = -1;
}

// CLEAR button to clear all lines and stop webcam
void Clear() {
  triOsc.stop();
  lines.clear();
  cam.stop();
  play = false;
}

// UNDO button to remove last line drawn
void Undo() {
  if (lines.size() > 0) {
    lines.remove(lines.size() - 1);
  }
}


/* ----- Audio Functions ----- */
// Convert MIDI note number to frequency
float midiToFreq(int note) {return (pow(2, ((note-69)/12.0))) * 440;}

// Play note of each line
void playNote(int note, float a, float s, float sLvl, float r, float p) {
  triOsc.pan(p);
  triOsc.play(midiToFreq(note), map(volume, 0, 10, 0, 1.0)); // Play note
  env.play(triOsc, a, s, sLvl, r); // Apply ASDR effect to note
}

// Manipulate audio speed and volume based on hand movement
void camInteract() {
  if (cam.available()) {cam.read();}

  image(cam, width-240, height-180, 240, 180); // Show camera image

  if (cam.width == 0) {return;}
  
  // Copy camera image for detection
  inputImage.copy(cam, 0, 0, cam.width, cam.height, 0, 0, inputImage.width, inputImage.height);
  inputImage.resize(240, 180);
  
  // Run detection
  yolo.setConfidenceThreshold(0.5f);
  detections = yolo.run(inputImage); 

  pushMatrix();
  translate(width-240, height-180);
  for (ObjectDetectionResult detection : detections) {
    int x = detection.getX(), y = detection.getY();
    int w = detection.getWidth(), h = detection.getHeight();
    
    // Draw detecting square
    noFill();
    strokeWeight(2f);
    stroke(color(255, 0, 0));
    rect(x, y, w, h);

    fill(0);
    text(nf(detection.getConfidence(), 0, 2), x, y);
    
    // Audio manipulation determined by area occupied by hand on screen
    if ((x+(x+w))/2 < 120) { // If hand on left screen, change audio speed
      int size = w * h;
      tempo = int(map(size, 0, (240*180)/2, 40, 250)); // Larger area, higher speed, vice versa
      cp5.getController("tempo").setValue(tempo);
    } else { // If hand on right screen, change audio volume
      int size = w * h;
      volume = int(map(size, 0, (240*180)/2, 0, 10)); // Larger area, louder volume, vice versa
      cp5.getController("volume").setValue(volume);
    }
  }
  popMatrix();
}

/* ----- Mouse Interactive Functions ----- */
// To Store dot
void mousePressed() {
  if (mouseY > 140 && newLine) {
    line = new Line(mouseX, mouseY, cp.getColorValue(), lineW);
    newLine = false;
  }
}

// Create new line and track cursor movement
void mouseDragged() {
  if (mouseY > 140) {
    if (newLine) { // Create new line
      line = new Line(mouseX, mouseY, cp.getColorValue(), lineW);
      newLine = false;
    } else {line.addPoint(mouseX, mouseY);} // Track cursor movement and store points
    
    // Draw line following cursor movement
    noFill();
    stroke(cp.getColorValue());
    strokeWeight(lineW);
    beginShape();
    for (PVector p: line.points) {
      curveVertex(p.x, p.y);
    }
    endShape();
  }
}

// Store drawn line and setup note's properties
void mouseReleased() {
  if (mouseY > 140) {
    line.addPoint(mouseX, mouseY);
    line.setASDR();
    playNote(line.note, line.attack, line.sustain, line.sustainLvl, line.release, line.pan);
    lines.add(line);
    newLine = true;
  }
}


/* ----- Main Program----- */
void setup() {
  size(1000, 1000);
  background(255);
  
  // Line Setup
  lines = new ArrayList<Line>();  
  clr = color(0);
  lineW = 2;
  
  // Divide drawing board into several levels
  levels = new PVector[12];
  float lvl = float(height - 140) / 12;
  for (int i = 0; i < 12; i++) {
    levels[i] = new PVector(140+lvl*i, 140+(lvl*(i+1))); // Assign MIDI note number to each level
  }
  
  // Audio Setup
  triOsc = new TriOsc(this);
  env = new Env(this);
  
  // GUI Setup
  cp5 = new ControlP5(this);
  
  // Colour Picker
  cp = new MyColorPicker(cp5, "hacktastic");
  cp.setPosition(10, 65).setColorValue(color(0)).setWidth(300);
  cp.setItemSize(300, 20);
  cp.setCaptionLabel("Colour");
  
  // Slider for line thickness
  cp5.addSlider("lineWeight").setPosition(390, 85)
                             .setRange(1, 7)
                             .setSize(150, 30)
                             .setNumberOfTickMarks(7)
                             .setValue(2);
  cp5.getController("lineWeight").setCaptionLabel("");
  cp5.getController("lineWeight").getValueLabel().setSize(15);
  
  // Slider for audio speed
  cp5.addSlider("tempo").setPosition(550, 85)
                        .setRange(40, 250)
                        .setSize(150, 30);
  cp5.getController("tempo").setCaptionLabel("");
  cp5.getController("tempo").getValueLabel().setSize(15);
  
  // Slider for audio volume
  cp5.addSlider("volume").setPosition(710, 85)
                        .setRange(0, 10)
                        .setSize(150, 30);
  cp5.getController("volume").setCaptionLabel("");
  cp5.getController("volume").getValueLabel().setSize(15);
  
  // PLAY Button
  cp5.addButton("Play").setPosition(880, 30)
                       .setSize(100, 30)
                       .setColorBackground(color(0))
                       .setColorForeground(color(100))
                       .setColorActive(color(150));
  cp5.getController("Play").getCaptionLabel().setSize(20);
  
  // CLEAR Button
  cp5.addButton("Clear").setPosition(880, 65)
                        .setSize(100, 30)
                        .setColorBackground(color(0))
                        .setColorForeground(color(100))
                        .setColorActive(color(150));
  cp5.getController("Clear").getCaptionLabel().setSize(20);
  
  // UNDO Button
  cp5.addButton("Undo").setPosition(880, 100)
                        .setSize(100, 30);
  cp5.getController("Undo").getCaptionLabel().setSize(20);
  
  // Webcam Setup
  println("Creating model...");
  yolo = deepVision.createCrossHandDetector(256);

  println("Loading YOLO model...");
  yolo.setup();

  cam = new Capture(this, "pipeline:autovideosrc");
  inputImage = new PImage(320, 240, RGB);
}


void draw() {
  background(255);
  
  // Draw toolbar
  fill(200);
  noStroke();
  rect(0, 0, width, 140);
  
  // Program Title
  fill(0);
  textSize(35);
  textAlign(CENTER, TOP);
  text("Draw Your Music!", width/2, 18);
  
  // Tool Name
  textSize(20);
  textAlign(LEFT, TOP);
  text("COLOUR", 10, 45);
  text("WEIGHT", 390, 65);
  text("TEMPO", 550, 65);
  text("VOLUME", 710, 65);
  
  // Colour Box
  clr = cp.getColorValue();
  fill(clr);
  noStroke();
  rect(315, 65, 62, 62);
  
  stroke(0);
  strokeWeight(5);
  line(0, 140, width, 140);
  
  // Draw lines
  noFill();
  for(int i = 0; i < lines.size(); i++) {
    Line l = lines.get(i);
    if (play) { // If audio playing
      // Line transparency determined by mouseY (within drawing board)
      float alpha;
      if (mouseY > 140) {alpha = map(mouseY, 140, height, 20, 255);}
      else {alpha = 255;}
      
      if (i == count) {l.draw(true, 255, tempo);} // If note of line is playing, line is thickened with no transparency
      else {l.draw(false, alpha, tempo);}
    }
    else {l.draw(false, 255, tempo);}
  }
  
  if (play) {camInteract();} // If audio is playing, run hand detection through webcam
  
  // Play notes in drawing order
  if (millis() > trigger && lines.size()-1 > count && play) {
    count++;
    Line l = lines.get(count);
    playNote(l.note, l.attack, l.sustain, l.sustainLvl, l.release, l.pan);
    trigger = millis() + (60.0/tempo)*1000 + l.sustain*1000;
  }
  
  // Stop webcam when audio ends
  if (millis() > trigger && lines.size()-1 == count) {
    count = -1;
    play = false;
    cam.stop();
  }

}
