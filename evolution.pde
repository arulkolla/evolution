final int MARGIN = 50;
final int MIN_RADIUS = 5, MAX_RADIUS = 15;
final float LIMIT = 5;
final float FOOD_ENERGY = 25;
final float MOVEMENT_PENALTY = 0.055;
final float REPRODUCTION_THRESHOLD = 25;
final float MUTATION_PROB = 0.01, MUTATION_SIZE = 0.9;
final int NUM_GENS = 5, LIFETIME = 75;

boolean go = true;
int lifetime, counter, gen;
World world;

class World {
  ArrayList<Creature> pop = new ArrayList<Creature>();
  ArrayList<Food> feed = new ArrayList<Food>();
  int popSize = 40, foodSize = 100;
  boolean[] dead = new boolean[popSize + 7];
  boolean[] nommed = new boolean[foodSize + 7];
          
  class Creature {
    float size, health;
    PVector pos, vel, acc;
    int ind;
    color col;
    Creature(float xPos, float yPos, float size, int ind) {
      this.size = size;
      this.ind = ind;
      this.pos = new PVector(xPos, yPos);
      this.vel = new PVector();
      this.acc = new PVector();
      this.col = color(int(random(0, 256)), int(random(0, 256)), int(random(0, 256)));
      this.health = 100.0;
    }
    
    Creature(float xPos, float yPos, float size, int ind, color col) {
      this.size = size;
      this.ind = ind;
      this.pos = new PVector(xPos, yPos);
      this.vel = new PVector();
      this.acc = new PVector();
      this.col = col;
      this.health = 100.0;
    }
    
    float getX() {return pos.x;}
    float getY() {return pos.y;}
    float getSize() {return size;}
    void setX(float x) {this.pos.x = x;}
    void setY(float y) {this.pos.y = y;}
    void setInd(int i) {this.ind = i;}
    
    void display() {
      stroke(0);
      strokeWeight(2);
      fill(this.col);
      circle(this.pos.x, this.pos.y, 2 * size);
      text(this.health, this.pos.x + this.size + 2, this.pos.y);
    }  
    
    void checkEdges() {
      PVector oldPos = this.pos;
      if (dist(this.pos.x, this.pos.y, width / 2, height / 2) + this.size >= min(width / 2 - MARGIN, height / 2 - MARGIN) + MAX_RADIUS) {
        this.pos = oldPos;
        PVector v = PVector.fromAngle(atan2(height / 2 - this.pos.y, width / 2 - this.pos.x));
        this.vel.set(v);
      }  
    }  
    
    void update() {
      this.acc = PVector.random2D();
      this.acc.mult(random(2));
      this.vel.add(this.acc);
      this.vel.limit(LIMIT);
      this.pos.add(this.vel);
    }
    
    // die
    void die() {
      this.size = 0;
      this.health = 0;    
      dead[this.ind] = true;
    }  
    
    // we eat another creature
    void eat(Creature other) {
      this.health += other.health / 10; //one-tenth rule
      other.die();
    }  
    
    void eat(Food other) {
      this.health += other.energy / 10; //one-tenth rule
      other.die();
    }
    
    void move() {
      this.update();
      this.checkEdges();
      this.health -= MOVEMENT_PENALTY * size; //lose energy by moving
      if (this.health <= 0) {this.die();}
    }  
  } 
  
  class Food {
    float size, energy;
    int ind;
    PVector pos;
    color col;
    
    Food(PVector pos, int ind) {
      this.size = 3;
      this.energy = FOOD_ENERGY;
      this.col = color(0, 255, 34);
      this.pos = pos;
      this.ind = ind;
    }
    
    void display() {
      stroke(0);
      strokeWeight(2);
      fill(this.col);
      ellipse(this.pos.x, this.pos.y, 2 * size + 5, 2 * size);
    }
    
    void die() {
      this.size = 0;
      nommed[this.ind] = true;
    }  
  }
  
  void drawBack() {
    background(140, 71, 41);
    strokeWeight(2);
    fill(0, 80, 28);
    int circleRadius = min(width / 2 - MARGIN, height / 2 - MARGIN);
    circle(width / 2, height / 2, 2 * (circleRadius + MAX_RADIUS)); 
  }
  
  void collide() {
    ArrayList<Integer> eaten = new ArrayList<Integer>(), eater = new ArrayList<Integer>();
    for (int i = 0; i < pop.size(); i++) {
      for (int j = i + 1; j < pop.size(); j++) {
        Creature c1 = pop.get(i), c2 = pop.get(j);
        if (dead[c1.ind] || dead[c2.ind]) {
          continue;
        }
        float dist = PVector.dist(c1.pos, c2.pos);
        if (dist < c1.size + c2.size - 5) {
          if (c1.size < c2.size) {
            eaten.add(c1.ind);
            dead[c1.ind] = true;
            eater.add(c2.ind);
          }
          else {
            eaten.add(c2.ind);
            dead[c2.ind] = true;
            eater.add(c1.ind);
          } 
        }
      }
    }
    for (int i = 0; i < eater.size(); i++) {
      pop.get(eater.get(i)).eat(pop.get(eaten.get(i)));  
    }  
  }  
  
  void consume() {
    ArrayList<Integer> eaten = new ArrayList<Integer>(), eater = new ArrayList<Integer>();
    for (int i = 0; i < pop.size(); i++) {
      for (int j = 0; j < feed.size(); j++) {
        Creature c = pop.get(i); 
        Food f = feed.get(j);
        if (dead[c.ind] || nommed[f.ind]) {continue;}
        float dist = PVector.dist(c.pos, f.pos);
        if (dist < c.size + f.size) {
          eaten.add(f.ind);
          nommed[f.ind] = true;
          eater.add(c.ind);
        }  
      }
    }  
    for (int i = 0; i < eater.size(); i++) {
      pop.get(eater.get(i)).eat(feed.get(eaten.get(i)));
    }  
  } 
  
  World() {
    int circleRadius = min(width / 2 - MARGIN, height / 2 - MARGIN);
  
    for (int i = 0; i < popSize; i++) {
      Creature now = new Creature(circleRadius * cos(TAU * i / popSize) + width / 2, circleRadius * sin(TAU * i / popSize) + height / 2, random(MIN_RADIUS, MAX_RADIUS), i);
      pop.add(now);
    } 
    
    PVector toMiddle = new PVector(width / 2, height / 2);
    
    for (int i = 0; i < foodSize; i++) {
      PVector now = PVector.fromAngle(random(0, 360));
      now.setMag(circleRadius * sqrt(random(0, 1)));
      now.add(toMiddle);
      Food curr = new Food(now, i);
      feed.add(curr);
    }  
  }
  
  void mark() {
    strokeWeight(2);
    for (Creature c : pop) {
      c.display();
    }
    for (Food f : feed) {
      f.display(); 
    }   
  }  
  
  void remark() {
    int circleRadius = min(width / 2 - MARGIN, height / 2 - MARGIN);
    
    for (int i = 0; i < pop.size(); i++) {
      Creature curr = pop.get(i);
      curr.setX(circleRadius * cos(TAU * i / pop.size()) + width / 2);
      curr.setY(circleRadius * sin(TAU * i / pop.size()) + height / 2);
      curr.setInd(i);
    }
    
    feed.clear();
    
    PVector toMiddle = new PVector(width / 2, height / 2);
    
    for (int i = 0; i < foodSize; i++) {
      PVector now = PVector.fromAngle(random(0, 360));
      now.setMag(circleRadius * sqrt(random(0, 1)));
      now.add(toMiddle);
      Food curr = new Food(now, i);
      feed.add(curr);
    }  
    
    dead = new boolean[pop.size() + 7];
    nommed = new boolean[feed.size() + 7];
    
    strokeWeight(2);
    for (Creature c : pop) {
      c.display();
    }
    for (Food f : feed) {
      f.display(); 
    }
    
  }
  
  void run() {
    drawBack(); 
    for (Creature c : pop) {
      if (!dead[c.ind]) {c.move();}
    } 
    collide();
    consume();
    for (Creature c : pop) {
      if (!dead[c.ind]) {c.display();}
    } 
    for (Food f : feed) {
      if (!nommed[f.ind]) {f.display();}
    }
  }
  
  void reproduce() {
    for (int i = pop.size() - 1; i >= 0; i--) {
      Creature curr = pop.get(i);
      float currHealth = curr.health;
      if (currHealth >= REPRODUCTION_THRESHOLD) {
        // reproduce (double), maybe mutate  
        float newSize = curr.getSize();
        if (random(0, 1) < MUTATION_PROB) {newSize *= random(MUTATION_SIZE, 1 / MUTATION_SIZE);}
        Creature baby = new Creature(curr.getX(), curr.getY(), newSize, pop.size(), curr.col);
        pop.add(baby);
      }
      else if (currHealth > 0) {
        // stay alive (do nothing)
      }
      else {
        // die
        // note: cells here will already have died, but we'll remove them
        if (dead[curr.ind]) {
          pop.remove(curr.ind);
        }
      }  
    }
  }
  
  void printSizes() {
    print("=SPLIT(\"");
    for (Creature c : pop) {
      if (c.size > 0) {print(c.size); print(", ");}
    }
    print("\", \", \")");
	print("\n");
  }  
}  

void setup() {
  size(600, 600);
  frameRate(30); 
  // PFont mon = createFont("andalemo.ttf", 16); textFont(mon);
  lifetime = LIFETIME;
  counter = 0;
  gen = 1;
  world = new World();
  world.mark();
}

void draw() {
  if (gen <= NUM_GENS && counter < lifetime) {
    counter++;
    world.run();
    fill(255, 255, 255);
    text(LIFETIME - counter, 30, 30);
    text(gen, 30, 50);
  }
  else if (gen <= NUM_GENS) {
    counter = 0;
    gen++;
    world.reproduce();
    world.remark();
  } 
  else {
    noLoop();
    world.printSizes();
    exit();
  }  
} 
  
void keyTyped() {
  if (int(key) == 32) {
    if (go == true) {
    noLoop(); go = false;
    world.printSizes();
  }
    else {loop(); go = true;}
  }  
}
