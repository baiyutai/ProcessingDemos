// initialize obstacle settings
static int maxNumObstacles = 1000;
// initialize circle obstacles
int numCircle = 50;
Vec2 circlePos[] = new Vec2[maxNumObstacles/2];
float circleRad[] = new float[maxNumObstacles/2];
// initialize box obstacles
int numBox = 50;
Vec2 boxTopLeft[] = new Vec2[maxNumObstacles/2];
float[] boxW = new float[maxNumObstacles/2];
float[] boxH = new float[maxNumObstacles/2];

// initialize prm settings
int numNodes  = 500;
RoadMap prm;

// initialize path settings
Vec2 startPos = new Vec2(100,500);
Vec2 goalPos = new Vec2(500,200);
ArrayList<Integer> curPath;

// initialize agent settings
float agentRad = 20.0;
Agent myAgent;

void setup(){
  size(1024,768);
  
  // place obstacles
  placeRandomObstacles(numCircle, numBox);
  
  // create start & goal
  startPos = sampleFreePos();
  goalPos = sampleFreePos();
  myAgent = new Agent(startPos, agentRad);
  
  // create prm
  prm = new RoadMap(numNodes, circlePos, circleRad, numCircle, boxTopLeft, boxW, boxH, numBox);
  // path plan
  curPath = prm.planPath(startPos, goalPos, circlePos, circleRad, numCircle, boxTopLeft, boxW, boxH, numBox);
  // add path goals to agent
  if (curPath.size() == 1 && curPath.get(0) == -1)
    return;
  for (int ind : curPath)
    myAgent.addGoal(prm.nodePos[ind]);
  myAgent.addGoal(goalPos);
}

void draw(){
  myAgent.step(1.0);
  
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
    rect(c.x+agentRad, c.y+agentRad, boxW[i]-agentRad*2, boxH[i]-agentRad*2);
  }
      
  //Draw Start and Goal
  fill(20,60,250);
  circle(startPos.x,startPos.y,20);
  fill(250,30,50);
  circle(goalPos.x,goalPos.y,20);
  fill(200, 255, 200);
  myAgent.display();
  
  //Draw Planned Path
  prm.displayPath(startPos, goalPos, curPath);
}

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
