final float[][] COLORS = 
{ {100,100,200}, {50,100,255}, {255,200,100},
{60,70,90}, {100,255,140}, {255,255,100},
{255,100,40}, {50,50,255}, {100,50,240}, {60,100,200} };

final String[] streak = { "POGGIES", "WOW", "AMAZING", "PogU", "Pog", "EZ", "Clap",
"PogChamp", "PagChomp", "AYAYA Clap"};

long clocktime;
int timeT;
ArrayList<Rocket> rocketList;
boolean hit;
PVector goal;
int chosenText;
boolean drag;
Rocket chosenRocket;
final PVector gravity = new PVector(0,0.1);
int score;
float radius;

void setup() {
  size(640, 640, P3D);
  float[] c = {255,100,150};
  clocktime = 0;
  timeT = 0;
  rocketList = new ArrayList<Rocket>();
  for (int i = 0; i < 10; i++)
  {
    rocketList.add(new Rocket(75 + (54*i), 550, (int)random(6,9), COLORS[i]));
  }
  goal = new PVector(320,220);
  score = 0;
  radius = 300;
}

void draw() {
  
  background(0);
  
  textSize(32);
  fill(255);
  String s = "Score: " + Integer.toString(score);
  text(s, 450, 80);
  text("Press R to reload", 10, 480);
  
  
  stroke(255);
  strokeWeight(3);
  noFill();
  circle(goal.x, goal.y, radius);
  for (Rocket r : rocketList) {
    r.selfDraw();
  }
  
  if (timeT > 0)
  {
    textSize(32);
    fill(timeT);
    text(streak[chosenText], 70, 80);
    timeT -= 3;
  }
  
  if (drag)
  {
   if (chosenRocket.origin.x > 640)
    drag = false;
   else {
     drawArrow();
   }
  }
  
  clocktime++;
}

void keyPressed() {
 if (key == 'e')
   displayText();
 else if (key == 'r')
 {
   rocketList.clear();
   for (int i = 0; i < 10; i++)
   {
    rocketList.add(new Rocket(75 + (54*i), 550, (int)random(6,9), COLORS[i]));
   }
 }
}

void mousePressed() {
 
  for (Rocket r : rocketList)
  {
   
    if (r.checkLit(mouseX, mouseY))
    {
       hit = true;
       r.lit();
       chosenRocket = r;
    }
  }
  
}

void mouseDragged() {
  
  if (hit)
  {
    drag = true;
  }
  
}

void mouseReleased() {
   hit = false;
   
   if (drag)
   {
     float deltaX = (mouseX - chosenRocket.origin.x)/20;
     float deltaY = (mouseY - chosenRocket.origin.y)/20;
     
     chosenRocket.velocity = new PVector(deltaX,deltaY);
     chosenRocket.angle = calculateAngle(chosenRocket.origin, mouseX, mouseY);
     chosenRocket.move = true;
     drag = false;
   }
}


class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  float[] colour = new float[3];
  int type;

  ParticleSystem(PVector position, float[] c, int t) {
    origin = position;
    particles = new ArrayList<Particle>();
    colour = c;
    type = t;
  }

  void addParticle() {
    
    float[] c = new float[3];
    for (int i = 0; i < 3; i++)
      c[i] = random(colour[i]-50, colour[i]+50);
    
    if (type == 2)
      particles.add(new Particle(origin, colour, type));
    else
    {
      particles.add(new Particle(origin, c, type));
      particles.add(new Particle(origin, c, type));
      particles.add(new Particle(origin, c, type));
      particles.add(new Particle(origin, c, type));
    }
  }

  void run() {
    for (int i = 0; i < particles.size(); i++) {
      Particle tempP = particles.get(i);
      tempP.run();
      if (tempP.isDead()) {
        particles.remove(i);
      }
    }
  }
  
  void changeType() {
   type = 1; 
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
    if (type == 2)
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
    }
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
      drawStar(position.x,position.y,size);
    else if (type == 1)
      drawStar2(position.x,position.y,size);
    else if (type == 2)
      circle(position.x, position.y, size);
    //drawShard(position.x,position.y,8);
    //drawStar(position.x,position.y,10);
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


PVector[] calculateRocketPoints(float x, float y, int size) {
  PVector[] points = new PVector[7];
  points[0] = new PVector(x - size, y + 2*size);
  points[1] = new PVector(x + size, y + 2*size);
  points[2] = new PVector(x + size, y - 2*size);
  points[3] = new PVector(x, y - 4*size);
  points[4] = new PVector(x - size, y - 2*size);
  points[5] = new PVector(x, y + 2*size);
  points[6] = new PVector(x, y + 8*size);
  
  return points;
}

class Rocket {
  PVector origin;
  PVector[] points;
  float[] colour;
  boolean lit;
  boolean explose;
  boolean move;
  ParticleSystem explosion;
  ParticleSystem burn;
  long exploseTime;
  float angle;
  PVector velocity;
  boolean dead;
  
  public Rocket(float x, float y, int size, float[] c) {
    points = calculateRocketPoints(x,y,size);
    origin = new PVector(x,y);
    colour = c;
    explosion = new ParticleSystem(origin, c, 0);
    float[] cb = {255,50,50};
    burn = new ParticleSystem(points[6], cb, 2);
    lit = false;
    explose = false;
    angle = 0;
    move = false;
  }
  
  void selfDraw() {
    if (move) {
     move(); 
    }
    
    
    
    if (!explose) {
      pushMatrix();
      if (move) {
        translate(origin.x,origin.y);
        rotate(angle);
        translate(-origin.x,-origin.y);
      }
      stroke(255);
      strokeWeight(2);
      fill(colour[0], colour[1], colour[2]);
      beginShape(POLYGON);
      for (int i = 0; i < 5; i++)
      {
        vertex(points[i].x,points[i].y); 
      }
      vertex(points[0].x,points[0].y); 
      endShape();
      stroke(120);
      beginShape(LINES);
      vertex(points[5].x,points[5].y);
      vertex(points[6].x,points[6].y);
      endShape();
      popMatrix();
    } else {
      if (!dead) {
        explosion.addParticle();
        if (clocktime > exploseTime+10)
          dead = true;
      }
    }
    explosion.run();
    pushMatrix();
    PVector tempPos = calculateFuelPos(points[6],angle, origin);
    burn.origin = tempPos;
    //translate(-tempPos.x,-tempPos.y);
    //rotate(angle);
    burn.run();
    if (lit) {
      burn.addParticle();
      burn();
    }
    burn.origin = points[6];
    popMatrix();
  }
  
  void explose() {
    lit = false;
    move = false;
    explose = true;
    exploseTime = clocktime;
    if (checkGoal(origin.x,origin.y))
    {
      displayText();
      explosion.changeType();
    }
  }
  
  void burn() {
    points[6].add(0,-0.5);
    if (points[6].y < points[5].y)
      explose();
  }
  
  void lit() {
   lit = true; 
  }
  
  boolean checkLit(float x0, float y0)
  {
    int count = 0;
    
    for (int i = 1; i < 5; i++)
    {
      if (checkIntersect(x0,y0,640,y0,points[i-1].x, points[i-1].y, points[i].x, points[i].y))
      {
          count++;
      }
    }
    
    if (checkIntersect(x0,y0,640,y0,points[0].x, points[0].y, points[4].x, points[4].y))
    {
       count++;
    }
    
    if (count % 2 != 0)
      return true;
    else
      return false;
  }
  
  void move() {
   velocity.add(gravity);
   origin.add(velocity);
   for (PVector point : points) {
    point.add(velocity); 
   }
  }
  
}

boolean checkIntersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
{
  float nom = (y4 - y3)*(x2 - x1) - (x4 - x3)*(y2 - y1);
  
  float ta = ((x4 - x3)*(y1 - y3) - (y4 - y3)*(x1 - x3))/nom;
  float tb = ((x2 - x1)*(y1 - y3) - (y2 - y1)*(x1 - x3))/nom;
  
  if (ta <= 1 && tb <= 1 && ta >= 0 && tb >= 0)
    return true;
  else
    return false;
}

boolean checkGoal(float x, float y)
{
  float l = dist(x, y, goal.x, goal.y);
  
  if (l <= radius/2)
    return true;
  else
    return false;
    
}

void displayText() {
  timeT = 255;
  chosenText = (int) random(0, streak.length - 0.5);
  score++;
  if (score % 5 == 0 && radius > 30)
    radius -= 30;
}


void drawArrow() {
  
  stroke(255,255,0);
  strokeWeight(3);
  beginShape(LINES);
  vertex(chosenRocket.origin.x,chosenRocket.origin.y);
  vertex(mouseX, mouseY);
  endShape();
  float angle = calculateAngle(chosenRocket.origin, mouseX, mouseY);
  pushMatrix();
  translate(mouseX,mouseY);
  rotate(angle);
  triangle(-6,4,6,4,0,-4);
  popMatrix();
  
}

float calculateAngle(PVector origin, float x, float y)
{
 float angle;
 float ox = origin.x;
 float oy = origin.y;
 
 float tempX = x - ox;
 float tempY = y - oy;
 
 if (y < oy)
   angle = atan(tempX/-tempY);
 else
   angle = atan(-tempX/tempY) + PI;
  
  return angle;
}

PVector calculateFuelPos(PVector p, float angle, PVector origin) {
  
  float x = p.x-origin.x;
  float y = p.y-origin.y;
  
  float x0 = x*cos(angle) - y*sin(angle);
  float y0 = x*sin(angle) + y*cos(angle);
  
  x0 += origin.x;
  y0 += origin.y;
  PVector result = new PVector(x0,y0);
  
  return result;
}
