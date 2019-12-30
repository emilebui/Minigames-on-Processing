final String textureS = "assets/sea.jpg";

PImage texture;
ParticleSystem d;
ParticleSystem f;
ParticleSystem j;
ParticleSystem k;
NoteMap map;
int time;
int combo;
int score;

float gravity = 4;
int interval = 20;


void setup() {
  size(640, 640, P3D);
  d = new ParticleSystem(new PVector(170,512), 3);
  f = new ParticleSystem(new PVector(270,512), 3);
  j = new ParticleSystem(new PVector(370,512), 3);
  k = new ParticleSystem(new PVector(470,512), 3);
  
  texture = loadImage(textureS);
  map = new NoteMap();
  time = 0;
  combo = 0;
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
  
  
  
  drawBar();
  d.run();
  f.run();
  j.run();
  k.run();
  //drawNote();
  map.run();
  time++;
}

void keyPressed() {
 if (key == 'd') {
   hitEffect(d, 0);
 } else if (key == 'f') {
   hitEffect(f, 1);
 } else if (key == 'j') {
   hitEffect(j, 2);
 } else if (key == 'k') {
   hitEffect(k, 3);
 }
}

void hitEffect(ParticleSystem origin, int type) {
  origin.startEff();
  
  if (map.checkHit(type))
  {
     combo++;
     score += 100 + combo*10;
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
      if (tempN.type == ty && tempN.checkHit()) {
        nList.remove(i);
        return true;
      }
    }
    
    return false;
  }
  
  
  void run() {
    
    for (Note n : nList) {
      n.move();
      n.drawN();
    }
   
    //This way it won't cause stutters
    for (int i = 0; i < nList.size(); i++) {
      Note tempN = nList.get(i);
      if (tempN.posY > 544) {
        combo = 0;
        nList.remove(i);
      }
    }
    
  }
}

class Note {
 
  float posX;
  float posY;
  ParticleSystem effect;
  int type;
  
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

  ParticleSystem(PVector position, int t) {
    origin = position;
    particles = new ArrayList<Particle>();
    type = t;
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
    acceleration = new PVector(0, 0.05);
    velocity = new PVector(random(-1, 1), random(-1, 2));
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
    float percentage = lifespan/120;
    stroke(255, lifespan);
    fill(50*percentage, 220*percentage, 250*percentage);
    
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
