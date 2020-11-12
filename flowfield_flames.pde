int rows;
int cols;
ArrayList<Particle> particles;
PVector[][] flowField;

float INCREMENT = 0.01;
int SCALE = 1;
float SPEED = 2.5;
int TRAIL_LENGTH = 80;
float BRIGHTNESS = 1;
int DENSITY = 20;
int R = 1, G = 1, B = 1;

//CHECK IF PALETTE CLICKED
void mouseClicked() {
  for(int i = 0; i < 3; i++){
    if(mouseX > width - 60 && mouseX < width - 10 && mouseY > 60 * i + 10 && mouseY < 60 * i + 60){
      switch(i){
        case 0:
          R = 1;
          G = 0;
          B = 0;
          break;
        case 1:
          R = 0;
          G = 1;
          B = 0;
          break;
        case 2:
          R = 0;
          G = 0;
          B = 1;
          break;
      }
    }
  }
}

void setup() {

  fullScreen();
  background(0);

  rows = floor(height/SCALE);
  cols = floor(width/SCALE);
  particles = new ArrayList();

  //CREATE FLOWFIELD
  flowField = new PVector[cols][rows];
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      float n = noise(x * INCREMENT, y * INCREMENT);

      PVector v = PVector.fromAngle(n * 4 * TWO_PI);
      flowField[x][y] = v;
    }
  }
}

void draw() {

  //ADD PARTICLES
  if (mousePressed) {
    for (int i = 0; i < DENSITY; i++) {
      particles.add(new Particle(mouseX, mouseY));
    }
  }

  //PARTICLE PHYSICS
  for (int i = 0; i < particles.size(); i++) {
    Particle p = particles.get(i);

    p.move();
    if (p.outOfBounds() || p.expired()) {
      particles.remove(p);
      continue;
    }

    int x = floor(p.pos.x / SCALE);
    int y = floor(p.pos.y / SCALE);
    PVector force = flowField[x][y];
    p.applyForce(force);
  }

  //DRAW PARTICLES
  loadPixels();
  noFill();
  for (Particle p : particles) {
    p.show();
  }
  updatePixels();
  
  //DRAW COLOUR PALETTE
  stroke(255);
  strokeWeight(3);
  fill(255, 0, 0);
  rect(width - 60, 10, 50, 50);
  fill(0, 255, 0);
  rect(width - 60, 70, 50, 50);
  fill(0, 0, 255);
  rect(width - 60, 130, 50, 50);
}

//PARTICLE CLASS
class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  int lifespan = floor(random(20, TRAIL_LENGTH));
  int aliveFor = 0;
  float limit = random(SPEED, SPEED + 1);

  Particle(int x, int y) {
    pos = new PVector(x, y);
    vel = PVector.random2D().mult(random(SPEED));
    acc = new PVector(0, 0);
  }

  void move() {
    vel.add(acc);
    vel.limit(limit);
    pos.add(vel);
    acc.mult(0);
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void show() {
    int loc = floor(pos.x) + floor(pos.y) * width;
    int c = pixels[loc];
    float r = red(c) + BRIGHTNESS * R;
    float g = green(c) + BRIGHTNESS * G;
    float b = blue(c) + BRIGHTNESS * B;
    pixels[loc] = color(r, g, b);
  }

  boolean outOfBounds() {
    return (pos.x >= width || pos.x < 0 || pos.y >= height || pos.y < 0);
  }
  
  boolean expired() {
    if(aliveFor > lifespan) {
      return true;
    }
    aliveFor++;
    return false;
  }
}
