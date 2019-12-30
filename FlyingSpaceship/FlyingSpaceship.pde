final String[] textureS = {
 "assets/grass.jpg",
 "assets/sea.jpg",
};

PImage texture[];
World world;
float t;
float dis;
Vessel ship;
boolean turnleft;
boolean turnright;
boolean up;
boolean down;
float vx;
float heV;
boolean stop;
boolean perspective;
int exploseT;
int time;
float baseY;
MapData mapW;
float rate;
float runescore;

void setup() {
  size(640, 640, P3D);
  //colorMode(RGB, 1.0);
  //hint(DISABLE_OPTIMIZED_STROKE);
  
  textureMode(NORMAL);
  texture = new PImage[2];
  for (int i = 0; i < 2; i++)
  {
    texture[i] = loadImage(textureS[i]);
  }
  textureWrap(REPEAT);
  baseY = -1.4;
  world = new World();
  mapW = world.map;
  ship = new Vessel(0,-0.65);
  
  t = 0;
  dis = 0;
  vx = 0;
  heV = 0.5;
  stop = false;
  perspective = true;
  exploseT = 0;
  time = 0;
  rate = 15;
  frameRate(60);
  runescore = 0;
}

void draw() {
  //noLoop();
  resetMatrix();
  background(0, 0, 0);
  float myFloat = ((float)time /60) + runescore;
  String str = "Score: " + String.format("%.02f", myFloat);
  pushMatrix();
  ortho(-320,320,320,-320);
  textSize(32);
  scale(1,-1);
  fill(255);
  text(str, -300, -280);
  if (stop)
  text("GAME OVER", -300, -250);
  popMatrix();
  
  if (!perspective) {
    ortho(-1, 1, 1, -1, -2.2, 2.2);
    camera(0.2,0,0.2,0,0.2,0,-0.2,0.2,0);
  } else {
    frustum(-1, 1, 1, -1, 1, 6.2);
    camera(vx,-8,heV,vx,0,0,0,1,0);
  }
  
  pushMatrix();
  
  //world view
  if (!perspective)
    translate(0,0,-0.3);
  else {
    translate(0,-4.4,-0.55);
    scale(3.5);
  }
  if (!stop)
    ship.drawV();
  else {
    if (exploseT > 0) {
        ship.explose();
        exploseT--;
    } else
      ship.exploseRun();
    
  }
  
  //world move
  pushMatrix();
  translate(0,-dis,0);
  world.drawW();
  popMatrix();
  
  popMatrix();
  
  if (!stop) {
    dis += 0.005;
    move();
  }
  t += 0.025;
  
  if (world.checkCollision() && !stop) {
    stop = true;
    explose();
  }
  if (!stop)
    time++;
  
  //Change world
  if (time % 20 == 0 && !stop)
  {
    mapW.pop();
    float baseX = -0.55;
     Node tempN = new Node();
     for (int j = 0; j < 12; j++) {
       int ran = (int) random(0,1.99);
       tempN.addT(new Tile(ran,baseX,baseY));
       
       float tempR = random(0,100);
       if (tempR < rate && baseY > -0.2)
       {
          int r = (int) random(0,3.9);
          float h = random(0.8,2);
          tempN.addO(new Object(r, h, baseX, baseY));
       }
       baseX += 0.1;
     }
     mapW.addNode(tempN);
     baseY += 0.1;
     rate += 0.2;
  }
}

void explose() {
  exploseT = 10;
}


class Tile {
 
  int text;
  float posX;
  float posY;
  
  public Tile(int t, float x, float y) {
    text = t;
    posX = x;
    posY = y;
  }
  
  void drawT() {
   
    pushMatrix();
    translate(posX,posY);
    scale(0.05);
    //fill(255,0,0);
    noStroke();
    beginShape(QUADS);
    texture(texture[text]);
    vertex(-1,-1,0,   0,1);
    vertex(1,-1,0,    1,1);
    vertex(1,1,0,     1,0);
    vertex(-1,1,0,    0,0);
    endShape();
    popMatrix();
  }
}

class Object {
 
  float he;
  int type;
  float posX;
  float posY;
  float sc;
  boolean consumed;
  
  public Object(int ty, float h, float x, float y)
  {
    type = ty;
    he = h;
    posX = x;
    posY = y;
    sc = 1;
    consumed = false;
  }
  
  void drawO()
  {
    if (sc > 0) {
    
    pushMatrix();
    translate(posX,posY);
    scale(0.05);
    
    if (consumed) {
      sc -= 0.1;
      scale(sc);
      runescore += 1;
    }
    if (type == 0)
      drawTree(he);
    else if (type == 1)
      drawPyramid(he);
    else if (type == 2)
      drawBox(he);
    else
      drawRune(he);
    popMatrix();
    
    }
  }
  
  boolean checkCollision() {
    float tempD = dist(posX,posY,vx,dis-0.65);
    
    if (!consumed && tempD < 0.05) {
      
      if (he >= heV) {
        
        if (type == 3) {
            consumed = true;
            //runescore += 10;
            return false;
        }
        
        return true;
      }
    }
    return false;
  }
  
}

class World {
  
  MapData map;
  
  public World() {
    map = new MapData();
    float baseX;
    
    for (int i = 0; i < 38; i++) {
    
     baseX = -0.55;
     Node tempN = new Node();
     for (int j = 0; j < 12; j++) {
       int ran = (int) random(0,1.99);
       tempN.addT(new Tile(ran,baseX,baseY));
       
       float tempR = random(0,100);
       if (tempR < 17 && baseY > -0.2)
       {
          int r = (int) random(0,3.1);
          float h;
          if (r < 2)
            h = random(1.5,2);
          else
            h = random(0.8,2);
          tempN.addO(new Object(r, h, baseX, baseY));
       }
       baseX += 0.1;
     }
     map.addNode(tempN);
     
     baseY += 0.1;
   }
    
  }
  
  void drawW() {
    map.drawMap();
  }
  
  boolean checkCollision() {
    return map.checkCol();
  }
  
  
  
}

void drawTree(float h) {
 
  pushMatrix();
  translate(0,0,0.15);
  stroke(230,230,230);
  strokeWeight(2.5);
  fill(30,50,30);
  box(0.4,0.4,0.3);
  popMatrix();
  pushMatrix();
  translate(0,0,0.3);
  pushMatrix();
  scale(h-0.3);
  drawTreeTop();
  popMatrix();
  popMatrix();
  
}

void drawPyramid(float h) {
 
  stroke(0,0,0);
  strokeWeight(5);
  fill(200,200,50);
  beginShape(TRIANGLE);
  vertex(-1,-1,0);
  vertex(1,-1,0);
  vertex(0,0,h);
  vertex(1,-1,0);
  vertex(1,1,0);
  vertex(0,0,h);
  vertex(1,1,0);
  vertex(-1,1,0);
  vertex(0,0,h);
  vertex(-1,1,0);
  vertex(-1,-1,0);
  vertex(0,0,h);
  endShape();
  
}

void drawTreeTop() {
 
  pushMatrix();
  scale(0.5);
  stroke(0,0,0);
  strokeWeight(5);
  fill(50,255,50);
  beginShape(TRIANGLE);
  vertex(-0.6,-0.6,0);
  vertex(0.6,-0.6,0);
  vertex(0,0,2);
  vertex(0.6,-0.6,0);
  vertex(0.6,0.6,0);
  vertex(0,0,2);
  vertex(0.6,0.6,0);
  vertex(-0.6,0.6,0);
  vertex(0,0,2);
  vertex(-0.6,0.6,0);
  vertex(-0.6,-0.6,0);
  vertex(0,0,2);
  endShape();
  popMatrix();
  
}

void drawBox(float h) {
  pushMatrix();
  translate(0,0,h/2);
  noStroke();
  fill(100,100,100);
  box(0.4,0.4,h);
  popMatrix();
  
  pushMatrix();
  rotate(t);
  translate(0.5,0.5,h/2);
  stroke(100,100,255);
  strokeWeight(10);
  fill(0,200,200);
  box(0.4,0.4,0.4);
  popMatrix();
  
  pushMatrix();
  rotate(t);
  translate(-0.5,-0.5,h/2);
  stroke(100,100,255);
  strokeWeight(10);
  fill(0,200,200);
  box(0.4,0.4,0.4);
  popMatrix();
  
}

void drawRune(float h) {
  
  pushMatrix();
  rotate(t);
  translate(0,0,h);
  stroke(255,0,0);
  strokeWeight(5);
  fill(170,30,255);
  box(1,1,1);
  popMatrix();
  
}

void drawVessel(float h) {
  
  pushMatrix();
  
  translate(0,0,h+0.3);
  
  if (turnleft)
    rotateY(-PI/3);
  else if (turnright)
    rotateY(PI/3);
  else if (up)
    rotateX(PI/6);
  else if (down)
    rotateX(-PI/6);
  
  //base
  stroke(0,255,0);
  strokeWeight(10);
  fill(200,0,0);
  beginShape(QUAD);
  vertex(-0.5,0,0);
  vertex(0,0,0.3);
  vertex(0.5,0,0);
  vertex(0,0,-0.3);
  endShape();
  
  
  //pyramid form
  beginShape(TRIANGLES);
  vertex(-0.5,0,0);
  vertex(0,0,0.3);
  vertex(0,1.5,0);
  
  vertex(0,0,0.3);
  vertex(0.5,0,0);
  vertex(0,1.5,0);
  
  vertex(0.5,0,0);
  vertex(0,0,-0.3);
  vertex(0,1.5,0);
  
  vertex(0,0,-0.3);
  vertex(-0.5,0,0);
  vertex(0,1.5,0);
  endShape();
  
  
  //2 wings
  stroke(255,0,0);
  strokeWeight(10);
  fill(0,100,255);
  beginShape(TRIANGLES);
  vertex(-0.5,0,0);
  vertex(-1,0,0);
  vertex(0,1,0);
  
  vertex(0.5,0,0);
  vertex(1,0,0);
  vertex(0,1,0);
  endShape();
  
  popMatrix();
  
}

class Vessel {
 
  float posX;
  float posY;
  ParticleSystem fuel;
  ParticleSystem ex;
  
  public Vessel(float x, float y) {
    posX = x;
    posY = y;
    float[] c = {255,100,100};
    fuel = new ParticleSystem(c,1);
    ex = new ParticleSystem(c,0);
  }
  
  void drawV() {
    
    pushMatrix();
    translate(posX,posY); 
    scale(0.05);
    drawVessel(heV);
    popMatrix();
    
    //fuel
    pushMatrix();
    translate(posX,posY, heV * 0.05);
    scale(0.1);
    fuel.addParticle();
    fuel.run();
    popMatrix();
    
  }
  
  void moveX() {
    posX = vx;  
  }
  
  void explose() {
    pushMatrix();
    translate(posX,posY, heV * 0.05);
    scale(0.1);
    ex.addParticle();
    ex.run();
    popMatrix();
  }
  
  void exploseRun() {
    pushMatrix();
    translate(posX,posY, heV * 0.05);
    scale(0.1);
    ex.run();
    popMatrix();
  }
}

void keyPressed() {
  
  if (key == 'd')
    turnright = true;
  else if (key == 'a')
    turnleft = true;
  else if (key == 'w')
    up = true;
  else if (key == 's')
    down = true;
  else if (key == 'r') {
    println("RELOADING");
    setup();
  }
}

void keyReleased() {
 
  if (key == 'd')
    turnright = false;
  else if (key == 'a')
    turnleft = false;
  else if (key == 'w')
    up = false;
  else if (key == 's')
    down = false;
  else if (key == ' ')
    perspective = !perspective;
}

void move() {
 
  if (turnleft) {
    if (vx > -0.55)
      vx -= 0.01;
  } else if (turnright) {
    if (vx < 0.55)
      vx += 0.01;  
  } else if (up) {
    if (heV < 1.5)
      heV += 0.02;
  }
  else if (down)
    if (heV > 0.5)
      heV -= 0.02;
  
  ship.moveX();
}

class ParticleSystem {
  ArrayList<Particle> parList;
  PVector origin;
  float[] colour = new float[3];
  int type;

  ParticleSystem(float[] c, int t) {
    origin = new PVector(0,0,0);
    parList = new ArrayList<Particle>();
    colour = c;
    type = t;
  }

  void addParticle() {
    
    float[] c = new float[3];
    for (int i = 0; i < 3; i++)
      c[i] = random(colour[i]-50, colour[i]+50);
    
    if (type == 1)
      parList.add(new Particle(origin, colour, type));
    else
    {
      parList.add(new Particle(origin, c, type));
      parList.add(new Particle(origin, c, type));
      parList.add(new Particle(origin, c, type));
      parList.add(new Particle(origin, c, type));
    }
  }

  void run() {
    for (int i = 0; i < parList.size(); i++) {
      Particle tempP = parList.get(i);
      tempP.run();
      if (tempP.isGone())
        parList.remove(i);
    }
  }
  
  void changeType() {
   type = 1; 
  }
}


class Particle {
  PVector pos;
  PVector velo;
  PVector acc;
  float life;
  float[] colour = new float[3];
  int type;
  float size;

  Particle(PVector l, float[] c, int t) {
    
    type = t;
    if (type == 1)
    {
      acc = new PVector(0, 0, -0.01);
      velo = new PVector(random(-0.01, 0.01), random(-0.08, -0.02), random(-0.01,0.01));
      size = random(0.01,0.03);
    }
    else
    {
      acc = new PVector(0, 0, 0);
      velo = new PVector(random(-0.04, 0.04), random(-0.04, 0.04), random(-0.1, 0.1));
      size = random(0.04,0.06);
    }
    pos = l.copy();
    if (type == 1)
      life = (int)random(15,25); //frames
    else
      life = (int)random(40,60); //frames
    for (int i = 0; i < 3; i++) {
      colour[i] = random(c[i]-100,c[i]);
    }
  }

  void run() 
  {
    move();
    display();
  }

  void move() 
  {
    life -= 1;
    velo.add(acc);
    pos.add(velo);
  }

  void display() {
    //float percentage = life/50;
    
    noStroke();
    //fill(colour[0]*percentage, colour[1]*percentage, colour[2]*percentage);
    fill(colour[0],colour[1],colour[2]);
    
    pushMatrix();
    translate(pos.x,pos.y);
    sphere(size);
    popMatrix();
  }

  boolean isGone() 
  {
    if (life < 0)
      return true;
    else
      return false;
  }
}

class Node {
 
  ArrayList<Tile> row;
  ArrayList<Object> rowO;
  
  Node next;
  
  public Node() {
    row = new ArrayList<Tile>();
    rowO = new ArrayList<Object>();
  }
  
  void addT(Tile t) {
   row.add(t); 
  }
  
  void addO(Object o) {
   rowO.add(o); 
  }
  
  void drawNode() {
   for (Tile t : row)
   {
    t.drawT(); 
   }
   for (Object o : rowO)
   {
    o.drawO(); 
   }
 }
 
 boolean checkCol() {
  
   for (Object o : rowO)
   {
      if (o.checkCollision())
        return true;
   }
   
   return false;
 }
}

class MapData {
  
  Node head;
  Node tail;
  
  public MapData() {
   head = null;
   tail = null;
  }
  
  void addNode(Node n) {
    if (head == null) {
       head = n;
       tail = n;
    } else {
       tail.next = n;
       tail = tail.next;
    }
  }
  
  void pop() {  
    if (head != null) {
       head = head.next;
       if (head == null)
         tail = null;
    } 
  }
  
  void drawMap() {
   Node curr = head;
   
   while (curr != null) {
     curr.drawNode();
     curr = curr.next;
   }
   
  }
  
  boolean checkCol() {
   
    Node curr = head;
    while (curr != null)
    {
       if (curr.checkCol())
         return true;
       curr = curr.next;
    }
    
    return false;
  }
}
