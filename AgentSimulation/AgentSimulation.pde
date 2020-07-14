int numCircle = 50, numBox = 50;
int numNodes  = 500;

//A list of circle obstacles
static int maxNumObstacles = 1000;
Vec2 circlePos[] = new Vec2[maxNumObstacles/2]; //Circle positions
float circleRad[] = new float[maxNumObstacles/2];  //Circle radii
//A list of box obstacles
Vec2 boxTopLeft[] = new Vec2[maxNumObstacles/2];
float[] boxW = new float[maxNumObstacles/2];
float[] boxH = new float[maxNumObstacles/2];

Vec2 startPos = new Vec2(100,500);
Vec2 goalPos = new Vec2(500,200);

static int maxNumNodes = 1000;
Vec2[] nodePos = new Vec2[maxNumNodes+2];

//Generate non-colliding PRM nodes
void generateRandomNodes(int numNodes, Vec2[] circleCenters, float[] circleRadii){
  for (int i = 0; i < numNodes; i++){
    Vec2 randPos = new Vec2(random(width),random(height));
    boolean insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numCircle,randPos);
    boolean insideAnyBox = pointInBoxList(boxTopLeft, boxW, boxH, numBox, randPos);
    while (insideAnyCircle || insideAnyBox){
      randPos = new Vec2(random(width),random(height));
      insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numCircle,randPos);
      insideAnyBox = pointInBoxList(boxTopLeft, boxW, boxH, numBox, randPos);
    }
    nodePos[i] = randPos;
  }
}

float agentRad = 10.0;
void placeRandomObstacles(int numCircle, int numBox){
  //Initial obstacle position
  for (int i = 0; i < numCircle; i++){
    circlePos[i] = new Vec2(random(50,950),random(50,700));
    circleRad[i] = agentRad+10+40*pow(random(1),2);
  }
  for (int i = 0; i < numBox; i++){
    boxTopLeft[i] = new Vec2(random(50,950), random(50,700));
    boxW[i] = agentRad*2+20+80*pow(random(1),2);
    boxH[i] = agentRad*2+20+80*pow(random(1),2);
  }
}

ArrayList<Integer> curPath;

int strokeWidth = 2;
void setup(){
  size(1024,768);
  testPRM();
}

Vec2 sampleFreePos(){
  Vec2 randPos = new Vec2(random(width),random(height));
  boolean insideAnyCircle = pointInCircleList(circlePos,circleRad,numCircle,randPos);
  boolean insideAnyBox = pointInBoxList(boxTopLeft, boxW, boxH, numBox, randPos);
  while (insideAnyCircle || insideAnyBox){
    randPos = new Vec2(random(width),random(height));
    insideAnyCircle = pointInCircleList(circlePos,circleRad,numCircle,randPos);
    insideAnyBox = pointInBoxList(boxTopLeft, boxW, boxH, numBox, randPos);
  }
  return randPos;
}

void testPRM(){

  placeRandomObstacles(numCircle, numBox);
  
  startPos = sampleFreePos();
  goalPos = sampleFreePos();

  generateRandomNodes(numNodes, circlePos, circleRad);
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numCircle, boxTopLeft, boxW, boxH, numBox, nodePos, numNodes);
}

void draw(){
  //println("FrameRate:",frameRate);
  strokeWeight(1);
  background(200); //Grey background
  noStroke();
  fill(255,255,255);
  
  //Draw the circle obstacles
  for (int i = 0; i < numCircle; i++){
    Vec2 c = circlePos[i];
    float r = circleRad[i]-agentRad;
    circle(c.x,c.y,r*2);
  }
  
  //Draw the box obstacles
  for (int i = 0; i < numBox; i++){
    Vec2 c = boxTopLeft[i];
    rect(c.x, c.y, boxW[i]-agentRad*2, boxH[i]-agentRad*2);
  }
      
  //Draw Start and Goal
  fill(20,60,250);
  circle(startPos.x,startPos.y,20);
  fill(250,30,50);
  circle(goalPos.x,goalPos.y,20);
  
  if (curPath.size() >0 && curPath.get(0) == -1) return; //No path found
  
  //Draw Planned Path
  stroke(20,255,40);
  strokeWeight(5);
  if (curPath.size() == 0){
    line(startPos.x,startPos.y,goalPos.x,goalPos.y);
    return;
  }
  line(startPos.x,startPos.y,nodePos[curPath.get(0)].x,nodePos[curPath.get(0)].y);
  for (int i = 0; i < curPath.size()-1; i++){
    int curNode = curPath.get(i);
    int nextNode = curPath.get(i+1);
    line(nodePos[curNode].x,nodePos[curNode].y,nodePos[nextNode].x,nodePos[nextNode].y);
  }
  line(goalPos.x,goalPos.y,nodePos[curPath.get(curPath.size()-1)].x,nodePos[curPath.get(curPath.size()-1)].y);
  
}

boolean shiftDown = false;
void keyPressed(){
  if (key == 'r'){
    testPRM();
    return;
  }
  
  if (keyCode == SHIFT){
    shiftDown = true;
  }
  
  float speed = 10;
  if (shiftDown) speed = 30;
  if (keyCode == RIGHT){
    circlePos[0].x += speed;
  }
  if (keyCode == LEFT){
    circlePos[0].x -= speed;
  }
  if (keyCode == UP){
    circlePos[0].y -= speed;
  }
  if (keyCode == DOWN){
    circlePos[0].y += speed;
  }
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numCircle, boxTopLeft, boxW, boxH, numBox, nodePos, numNodes);
}

void keyReleased(){
  if (keyCode == SHIFT){
    shiftDown = false;
  }
}

void mousePressed(){
  if (mouseButton == RIGHT){
    startPos = new Vec2(mouseX, mouseY);
    //println("New Start is",startPos.x, startPos.y);
  }
  else{
    goalPos = new Vec2(mouseX, mouseY);
    //println("New Goal is",goalPos.x, goalPos.y);
  }
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numCircle, boxTopLeft, boxW, boxH, numBox, nodePos, numNodes);
}
