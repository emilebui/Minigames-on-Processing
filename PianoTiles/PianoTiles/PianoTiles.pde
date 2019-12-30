final float GRAVITY = 16;  //HOW FAST NOTE MOVE DOWN
final int NOTENUM = 30;    //TO WIN

float currScreenY;
float downTime;
boolean stop;
float currY;
Map m;
int realtime;
boolean mode;
int numN;
boolean won;
boolean start;


void setup() {
  size(640, 640, P3D);
  currY = 480;
  m = new Map();
  stop = false;
  downTime = 0;
  currScreenY = 0;
  mode = true; //normal, false is endless
  numN = 0;
  won = false;
  frameRate(60);
  start = false;
  realtime = 0;
}

void draw() {
  background(30);
  
  pushMatrix();
  if (downTime > 0 && !(stop ^ won)) {
      currScreenY += GRAVITY; 
      downTime--;
  }
  translate(0,currScreenY);
  if (won) {
    textSize(32);
    fill(255,0,0);
    text("YOU WON", 250, -4500);
    float ti = ((float)realtime /60);
    String score = "Time: " + String.format("%.02f", ti);
    text(score, 240, -4400);
  }
  m.drawM();
  popMatrix();
  
  if (stop && !won) {
    textSize(32);
    fill(255,0,0);
    text("YIKES!!",280,200);
  }
  
  if (!stop && start) {
    realtime++;
    textSize(20);
    fill(255);
    float ti = ((float)realtime /60);
    String score = "Time: " + String.format("%.02f", ti);
    text(score, 40,80);
  }
  
  if (!start) {
    textSize(40);
    fill(255,0,0);
    text("D", 185,570);
    text("F", 265,570);
    text("J", 345,570);
    text("K", 425,570);
  }
}

void keyPressed() {
 
  if (!stop) {
    if (key == 'd')
      m.press(0);
    else if (key == 'f')
      m.press(1);
    else if (key == 'j')
      m.press(2);
    else if (key == 'k')
      m.press(3);
  }
  
  if (key == 'r')
    setup();
  else if (key == 'e') {
   setup();
   mode = false;
  }
}

class Tile { 
  
 boolean black;
 boolean pressed;
 float posX;
 float posY;
  
 public Tile(float x, float y, boolean b) {
   posX = x;
   posY = y;
   black = b;
   pressed = false;
 }
 
 void drawT() {
  
   pushMatrix();
   translate(posX,posY);
   if (black) {
     if (!pressed)
       fill(0);
     else
       fill(50);
   }
   else {
     if (!pressed)
       fill(255);
     else
       fill(255,0,0);
   }
   drawTile();  
   popMatrix();
   
 }
 
 void move() {
   posY += GRAVITY;
 }
 
 void pressed() {
   pressed = true;
   hitLogic();
   if (!black)
     stop = true;
   
 }
 
 boolean checkHit() {
   
  return false; 
 }
  
}

void hitLogic() {
  downTime += 10;
  if (mode) {
    numN++;
    if (numN < 26) {
      m.generatingRow();
    }
    
    if (numN == 29) {
      stop = true;
      won = true;
    }
  } else
    m.generatingRow();
  
  if (!start)
    start = true;
}

void drawTile() {
 stroke(0);
 strokeWeight(1);
 rect(0,0,80,160);
}


class Node {
 
  ArrayList<Tile> row;
  Node next;
  
  public Node() {
    row = new ArrayList<Tile>();
  }
  
  void addT(Tile t) {
   row.add(t); 
  }
  
  
  void drawNode() {
   for (Tile t : row)
   {
    t.drawT(); 
   }
 }
 
 boolean checkHit() {
  
   for (Tile t : row)
   {
      if (t.checkHit())
        return true;
   }
   
   return false;
 }
 
 boolean checkPressed() {
   
   for (Tile t : row) {
      if (t.pressed)
        return true;
   }
   
   return false;
 }
 
 void press(int pos) {
   Tile t = row.get(pos);
   t.pressed();
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
  
  boolean checkHit() {
    Node top = findTop(head);
    if (top != null)
      return top.checkHit();
    else
      return false;
  }
  
  Node findTop(Node curr) {
    if (curr == null)
      return null;
    
    if (curr.checkPressed())
      return findTop(curr.next);
    else
      return curr;
  }
  
  void press(int pos) {
    Node top = findTop(head);
    top.press(pos);
  }
  
}

class Map {
 
  MapData data;
  
  public Map() {
    data = new MapData();
    
    for (int i = 0; i < 4; i++) {
     generatingRow();
    }
  }
  
  void generatingRow() {
    int r = (int) random(0,4-0.01);
    Node tempN = new Node();
    
    for (int i = 0; i < 4; i++) {
      if (i == r)
        tempN.addT(new Tile(160 + (80*i),currY,true));
      else
        tempN.addT(new Tile(160 + (80*i),currY,false));
    }
    
    data.addNode(tempN);
    currY -= 160;
  }
  
  void drawM() {
    data.drawMap();
  }
  
  boolean checkHit() {
    return data.checkHit(); 
  }
  
  void press(int pos) {
    data.press(pos);
  }
}
