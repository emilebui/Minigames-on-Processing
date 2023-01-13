final float[][] COLORS = 
{ {255,50,50}, {50,100,255}, {255,200,100},
{60,70,90}, {100,255,140}, {255,255,100},
{255,100,40}, {50,50,255}, {100,50,240}, {60,100,200} };

ArrayList<ParticleSystem> psList;
float baseSize = 20;
long clocktime;
int timeT;



void setup() {
  size(640, 640, P3D);
  clocktime = 0;
  timeT = 0;
  psList = new ArrayList<ParticleSystem>();
}

void draw() {
   background(0);
   fill(255);
   //drawHeart(100, 100, 1.5);
   ParticleSystem tempP;
   for (int i = 0; i < psList.size(); i++) {
    tempP = psList.get(i);
    if (tempP.dead) {
      psList.remove(i);
    } else {
      tempP.run();
    }
  }
  explose(width/2, height/2, 10);
  
  if (clocktime == 2)
    explosion(width/2, height/2, 18);
  clocktime++;
  if (clocktime % 100 == 0)
    explosion(width/2, height/2, 18);
  
}

void mousePressed() {
  addPS(mouseX, mouseY, 0, 0, 4, 5);
}

void addPS(float x, float y, int c_num, int type, int flare, int dur) {
  PVector cord = new PVector(x, y);
  ParticleSystem tempP = new ParticleSystem(cord, COLORS[c_num], type, flare, dur);
  psList.add(tempP);
}


class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  float[] colour = new float[3];
  int type;
  int duration;
  boolean dead;
  int flare;
  boolean explosion;
  

  ParticleSystem(PVector position, float[] c, int t, int f, int dur) {
    origin = position;
    particles = new ArrayList<Particle>();
    colour = c;
    type = t;
    flare = f;
    duration = dur;
    dead = false;
  }

  void addParticle() {
    
    float[] c = new float[3];
    for (int i = 0; i < 3; i++)
      c[i] = random(colour[i]-50, colour[i]+50);
    
    for (int i = 0; i < flare; i++)
      particles.add(new Particle(origin, c, type));
  }

  void run() {
    if (duration > 0)
        this.addParticle();
        
    for (int i = 0; i < particles.size(); i++) {
      Particle tempP = particles.get(i);
      tempP.run();
      if (tempP.isDead()) {
        particles.remove(i);
      }
    }
    
    if (duration > 0)
       duration--;
    
    if (duration == 0 && particles.size() == 0)
      dead = true;
  }
}

class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float[] colour = new float[3];
  int type;
  float size;

  Particle(PVector l, float[] c, int t) {
    
    type = t;
    acceleration = new PVector(0, 0);
    velocity = new PVector(random(-1, 1), random(-1.75, 1));
    size = random(0.5,1);
    position = l.copy();
    lifespan = (int)random(70,80); //frames
    for (int i = 0; i < 3; i++) {
      colour[i] = random(c[i]-50,c[i]);
    }
    
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
    fill(colour[0]*percentage, colour[1]*percentage, colour[2]*percentage);
    
    if (type == 0)
      drawHeart(position.x,position.y,size);
    else if (type == 1)
      drawStar(position.x,position.y,size);
    else
      circle(position.x, position.y, baseSize*size);
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



void drawStar(float x, float y, float size) {
  
  PVector[] points = new PVector[5];
  float tempX, tempY;
  
  for (int i = 0; i < 5; i++)
  {
    tempX = (float)(baseSize*Math.cos(i*2*PI/5));
    tempY = (float)(baseSize*Math.sin(i*2*PI/5));
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


void drawHeart(float x, float y, float size) {
  smooth();
  beginShape();
  vertex(x, y);
  bezierVertex(x, y-20*size, x+40*size, y-10*size, x, y+25*size);
  endShape();
  beginShape();
  vertex(x, y);
  bezierVertex(x, y-20*size, x-40*size, y-10*size, x, y+25*size);
  endShape();
}


void explosion(float x, float y, float r) {
  
  for (float a = 0; a < TWO_PI; a+=0.1) {
      float tempX = r * 16 * pow(sin(a), 3);
      float tempY = -r * (13 * cos(a) - 5*cos(2*a) - 2*cos(3*a) - cos(4*a));
      addPS(x+tempX, y+tempY, 0, 0, 3, 1);
  }
  
}

void explose(float x, float y, float r) {
  
  float a = clocktime/25.0;
  
  float tempX = r * 16 * pow(sin(a), 3);
  float tempY = -r * (13 * cos(a) - 5*cos(2*a) - 2*cos(3*a) - cos(4*a));
  addPS(x+tempX, y+tempY, 0, 0, 3, 1);
  
  a = PI + clocktime/25.0;
  tempX = r * 16 * pow(sin(a), 3);
  tempY = -r * (13 * cos(a) - 5*cos(2*a) - 2*cos(3*a) - cos(4*a));
  addPS(x+tempX, y+tempY, 0, 0, 3, 1);
  
}
