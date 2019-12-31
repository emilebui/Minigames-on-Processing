final String textureS = "assets/sea.jpg";

PImage texture;
NoteMap map;
int time;
int combo;
int score;
int[] lightcolor;

float gravity = 4;
int interval = 20;


void setup() {
  size(640, 640, P3D);
  
  texture = loadImage(textureS);
  map = new NoteMap();
  time = 0;
  combo = 0;
  lightcolor = new int[4];
  for (int i = 0; i < 4; i++) {
     lightcolor[i] = 0; 
  }
}

void draw() {
  background(0);
  
  String s = "Score: " + Integer.toString(score);
  fill(255);
  textSize(32);
  text(s, 80, 80);
  
  if (combo > 1) {
    s = "Combo x" + Integer.toString(combo);
    fill(255);
    textSize(32);
    text(s, 240, 320);
  }
  
  if (time % interval == 0)
  {
    map.addNote(); 
  }
  
  
  displayEffect();
  drawBar();
  //drawNote();
  map.run();
  time++;
}

void keyPressed() {
 if (key == 'd') {
   hitEffect(0);
 } else if (key == 'f') {
   hitEffect(1);
 } else if (key == 'j') {
   hitEffect(2);
 } else if (key == 'k') {
   hitEffect(3);
 }
}

void hitEffect(int type) {
  lightcolor[type] = 255;
  
  if (map.checkHit(type))
  {
     combo++;
     score += 100 + combo*10;
  }
}

void lightEffect(int ty) {
  pushMatrix();
  noStroke();
  fill(lightcolor[ty]);
  rect(120 + (100*ty),0,100,524);
  popMatrix();
  lightcolor[ty] -= 17;
}

void displayEffect() {
 
  for (int i = 0; i < 4; i++) {
     if (lightcolor[i] > 0) {
        lightEffect(i); 
     }
  }
  
}

void drawBar() {
 
  stroke(255);
  strokeWeight(5);
  beginShape(LINES);
  vertex(120,500);
  vertex(520,500);
  vertex(120,524);
  vertex(520,524);
  endShape();
  
}

class NoteMap {
 
  ArrayList<Note> nList;
  
  public NoteMap() {
   nList = new ArrayList<Note>(); 
  }
  
  void addNote() {
   int r = (int) random(0,4-0.01);
   nList.add(new Note(r));
  }
  
  boolean checkHit(int ty) {
   
    for (int i = 0; i < nList.size(); i++) {
      Note tempN = nList.get(i);
      if (tempN.type == ty && tempN.checkHit() && !tempN.explose) {
        tempN.explose();
        return true;
      }
    }
    
    return false;
  }
  
  
  void run() {
    
    for (Note n : nList) {
      if (!n.explose) {
        n.move();
        n.drawN();
      } else {
        n.runEff();
      }
    }
   
    //This way it won't cause stutters
    for (int i = 0; i < nList.size(); i++) {
      Note tempN = nList.get(i);
      if (tempN.posY > 544) {
        combo = 0;
        nList.remove(i);
      }
      if (tempN.explose && tempN.isDead())
        nList.remove(i);
    }
    
  }
}

class Note {
 
  float posX;
  float posY;
  ParticleSystem effect;
  int type;
  boolean explose;
  int timeEff;
  
  public Note(int ty) {
    type = ty;
    posY = 0;
    if (type == 0)
      posX = 170;
    else if (type == 1)
      posX = 270;
    else if (type == 2)
      posX = 370;
    else if (type == 3)
      posX = 470;
      
    explose = false;
  }
  
  void move() {
    posY += gravity;
  }
  
  
  void drawN() {
    
    pushMatrix();
    translate(posX,posY);
    drawNote();
    popMatrix();
  }
  
  boolean checkHit() {
    if (posY >= 488 && posY <= 536)
      return true;
    return false;
  }
  
  void explose() {
     explose = true;
     effect = new ParticleSystem(new PVector(posX,posY));
     effect.startEff();
  }
  
  boolean isDead() {
     return effect.isDead(); 
  }
  
  void runEff() {
     effect.run(); 
  }
}


void drawNote() {
  stroke(255);
  strokeWeight(4);
  beginShape(QUADS);
  texture(texture);
  vertex(-50,-12,0,    0,320);
  vertex(50,-12,0,  320,320);
  vertex(50,12,0, 320,0);
  vertex(-50,12,0,   0,0);
  endShape();
}

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  int type;
  int effTime;

  ParticleSystem(PVector position) {
    origin = position;
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle(origin, type));
    particles.add(new Particle(origin, type));
  }

  void run() {
    if (effTime > 0)
    {
     effTime--;
     addParticle();
    }
    for (int i = 0; i < particles.size(); i++) {
      Particle tempP = particles.get(i);
      tempP.run();
      if (tempP.isDead()) {
        particles.remove(i);
      }
    }
  }
  
  void changeType() {
   type = (int) random(0, 4 - 0.1);
  }
  
  void startEff() {
   effTime = 10; 
   changeType();
  }
  
  boolean isDead() {
     if (particles.size() == 0) {
       //println("REMOVED");
       return true;
     }
     return false;
  }
}


class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  int type;
  float size;

  Particle(PVector l, int t) {
    
    type = t;
    acceleration = new PVector(0, 0.02);
    velocity = new PVector(random(-1, 1), random(-2, 0));
    size = random(7,14);
    /**if (type == 2)
    {
      acceleration = new PVector(0, 0.05);
      velocity = new PVector(random(-1, 1), random(0, 2));
      size = random(4,6);
    }
    else
    {
      acceleration = new PVector(0, 0);
      velocity = new PVector(random(-1, 1), random(-1.75, 1));
      size = random(7,14);
    }**/
    position = l.copy();
    lifespan = (int)random(70,80); //frames
    
  }

  void run() 
  {
    update();
    display();
  }

  void update() 
  {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1;
  }

  void display() {
    float percentage = lifespan/90;
    stroke(255,255,255, percentage*255);
    fill(50, 220, 250, percentage*255);
    
    if (type == 0)
      drawStar(position.x,position.y,size);
    else if (type == 1)
      drawStar2(position.x,position.y,size);
    else if (type == 2)
      circle(position.x, position.y, size);
    else
      drawShard(position.x,position.y,size);
  }

  boolean isDead() 
  {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}

void drawShard(float x, float y, float size) {
  beginShape(POLYGON);
  vertex(x-size,y);
  vertex(x,y-size);
  vertex(x+size,y);
  vertex(x,y+size);
  vertex(x-size,y);
  endShape();
}

void drawStar(float x, float y, float size) {
 
  PVector[] points = new PVector[5];
  float tempX, tempY;
  
  for (int i = 0; i < 5; i++)
  {
    tempX = (float)(size*Math.cos(i*2*PI/5));
    tempY = (float)(size*Math.sin(i*2*PI/5));
    tempX += x;
    tempY += y;
    points[i] = new PVector(tempX,tempY);
  }
  
  smooth();
  beginShape(POLYGON);
  vertex(points[0].x,points[0].y);
  vertex(points[2].x,points[2].y);
  vertex(points[4].x,points[4].y);
  vertex(points[1].x,points[1].y);
  vertex(points[3].x,points[3].y);
  vertex(points[0].x,points[0].y);
  endShape();
}

void drawStar2(float x, float y, float size) {
 
  PVector[] points = new PVector[6];
  float tempX, tempY;
  
  for (int i = 0; i < 6; i++)
  {
    tempX = (float)(size*Math.cos(i*2*PI/6));
    tempY = (float)(size*Math.sin(i*2*PI/6));
    tempX += x;
    tempY += y;
    points[i] = new PVector(tempX,tempY);
  }
  
  smooth();
  beginShape(TRIANGLES);
  vertex(points[0].x,points[0].y);
  vertex(points[2].x,points[2].y);
  vertex(points[4].x,points[4].y);
  vertex(points[1].x,points[1].y);
  vertex(points[3].x,points[3].y);
  vertex(points[5].x,points[5].y);
  endShape();
}
