// Line Class
class Line {
  // Line Variables
  ArrayList<PVector> points;
  color clr;
  float weight;
  
  // Note Variables
  int note;
  float attack;
  float sustain;
  float sustainLvl;
  float release;
  float pan;
  int count = 0; // Counter for animation
  
  // Constructor
  Line(float x, float y, color c, float w) {
    points = new ArrayList<PVector>();
    points.add(new PVector(x, y));
    clr = c;
    weight = w;
    note = getNote(y);
    pan = map(x, 0, width, -1.0, 1.0);
  }
  
  // Add cursor points
  void addPoint(float x, float y) {points.add(new PVector(x, y));}
  
  // Draw line
  void draw(boolean play, float alpha, float tempo) {
    noFill();
    stroke(clr, alpha);
    if (play) {strokeWeight(weight+5);} // If note of line is playing, line is thickened
    else {strokeWeight(weight);}
    
    beginShape();
    for (PVector p: points) {vertex(p.x, p.y);}
    endShape();
    
    // Animation - Trace line when note is playing
    if (play && count < points.size()) {
      fill(clr);
      circle(points.get(count).x, points.get(count).y, weight+5);
      int skip = ceil((1000.0/30)/((sustain+(60.0/tempo))*1000/points.size()))+1;
      count += skip;
    } else if (!play && count >= points.size()) {count = 0;}
  }

  // Determine note based on y-coordinate of line's first vertex
  int getNote(float y) {
    for (int i = 0; i < 12; i++) {
      if (y > levels[i].x && y <= levels[i].y) {
        return 107 - i - (12 * (int(weight)-1));
      }
    }
    return 0;
  }
  
  // Calculate ADSR value
  void setASDR() {
    attack = map(red(clr), 0, 255, 0.001, 1);
    sustain = points.size() * 0.01;
    sustainLvl = map(green(clr), 0, 255, 0.1, 3);
    release = map(blue(clr), 0, 255, 0.001, 2);
  }
}
