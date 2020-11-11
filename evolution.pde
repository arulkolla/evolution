final int MARGIN = 50;
final int MIN_RADIUS = 5, MAX_RADIUS = 15;

ArrayList<Creature> pop = new ArrayList<Creature>();
int popSize = 20;

class Creature {
  float size, limit; // size is radius
  PVector pos, vel, acc;
  color col;
  Creature(float xPos, float yPos, float size) {
    this.size = size;
    this.pos = new PVector(xPos, yPos);
    this.vel = new PVector();
    this.acc = new PVector();
    this.limit = 5;
    this.col = color(int(random(0, 256)), int(random(0, 256)), int(random(0, 256)));
  }
  
  float getX() {return pos.x;}
  float getY() {return pos.y;}
  float getSize() {return size;}
  
  void display() {
    strokeWeight(2);
    fill(this.col);
    circle(this.pos.x, this.pos.y, 2 * size);
  }  
  
  void checkEdges() {
      
  }  
  
  void update() {
    this.acc = PVector.random2D();
    this.acc.mult(random(2));
    this.vel.add(this.acc);
    this.vel.limit(this.limit);
    this.pos.add(this.vel);
  }
} 

void setup() {
  size(600, 600);
  frameRate(30);  
  
  background(140, 71, 41); 
  
  int circleRadius = min(width / 2 - MARGIN, height / 2 - MARGIN);
  
  for (int i = 0; i < popSize; i++) {
    Creature now = new Creature(circleRadius * cos(TAU * i / popSize) + width / 2, circleRadius * sin(TAU * i / popSize) + height / 2, random(MIN_RADIUS, MAX_RADIUS));
    pop.add(now);  
  } 
  
  strokeWeight(2);
  fill(0, 80, 28);
  circle(width / 2, height / 2, 2 * (circleRadius + MAX_RADIUS)); 
  for (Creature c : pop) {
    c.display();
  }  
}

void draw() {
  for (Creature c : pop) {
    c.update();
    c.display();
  } 
} 
