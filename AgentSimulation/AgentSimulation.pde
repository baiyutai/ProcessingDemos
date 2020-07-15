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

// camera parameters
Vec3 cameraPos, cameraDir;
float theta, phi;

void setup(){
  size(1024,768, P3D);

  // set camera parameters
  cameraPos = new Vec3(width/2.0, height/2.0, 750);
  theta = -PI/2; phi = PI/2;
  cameraDir = new Vec3(cos(theta)*sin(phi),cos(phi),sin(theta)*sin(phi));
  cameraDir.mul(800);
  
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
  myAgent.step(1.0, circlePos, circleRad, numCircle, boxTopLeft, boxW, boxH, numBox);
  cameraUpdate(0.05);
  
  //println("FrameRate:",frameRate);
  strokeWeight(1);

  // grey background
  background(200);
  // a cutting plane
  noStroke();
  fill(200);
  rect(0,0,5000,5000);
  // camera settings
  camera(cameraPos.x, cameraPos.y, cameraPos.z,
  cameraPos.x+cameraDir.x, cameraPos.y+cameraDir.y, cameraPos.z+cameraDir.z,
  0.0, 1.0, 0.0);

  // lights settings
  directionalLight(180, 180, 180, -1, 1, -1);
  ambientLight(150, 150, 150);
  specular(255);
  
  // obstacles settings
  fill(255);
  // draw the circle obstacles
  for (int i = 0; i < numCircle; i++){
    Vec2 c = circlePos[i];
    float r = circleRad[i]-agentRad;
    pushMatrix();
    translate(c.x, c.y, 0);
    sphere(r);
    popMatrix();
  }
  // draw the box obstacles
  for (int i = 0; i < numBox; i++){
    Vec2 c = boxTopLeft[i];
    float lenX = boxW[i]-agentRad*2, lenY = boxH[i]-agentRad*2, lenZ = agentRad*2;
    pushMatrix();
    translate(c.x+agentRad+lenX/2, c.y+agentRad+lenY/2, 0);
    box(boxW[i]-agentRad*2, boxH[i]-agentRad*2, agentRad*2);
    popMatrix();
  }
      
  // draw start
  fill(20,60,250);
  circle(startPos.x,startPos.y,20);
  // draw goal
  fill(250,30,50);
  circle(goalPos.x,goalPos.y,20);
  // draw agent
  fill(200, 255, 200);
  myAgent.display();
  
  // draw path
  stroke(20,255,40);
  strokeWeight(5);
  prm.displayPath(startPos, goalPos, curPath);
}

void placeRandomObstacles(int numCircle, int numBox){
  // initial obstacle position
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

// control camera according to keyboard and mouse inputs
void cameraUpdate(float step){
  if (ctrlPressed){
    Vec3 up = new Vec3(0.0,-1.0,0.0);
    up.subtract(cameraDir.times(cameraDir.y));
    up.normalize();
    if (upPressed) cameraPos.add(up.times(step*20));
    if (downPressed) cameraPos.subtract(up.times(step*20));
    Vec3 left = cross(cameraDir, up);
    if (leftPressed) cameraPos.add(left.times(step*20));
    if (rightPressed) cameraPos.subtract(left.times(step*20));
  }
  else{
    if (upPressed) phi += step;
    if (downPressed) phi -= step;
    if (leftPressed) theta -= step;
    if (rightPressed) theta += step;
    cameraDir.x = cos(theta)*sin(phi);
    cameraDir.y = cos(phi);
    cameraDir.z = sin(theta)*sin(phi);
  }
}
// control camera according to mouse input
void mouseWheel(MouseEvent event){
  cameraPos.add(cameraDir.times(-10*event.getCount()));
}

boolean leftPressed, rightPressed, upPressed, downPressed;
boolean ctrlPressed;
boolean wPressed, aPressed, sPressed, dPressed, qPressed, ePressed;
void keyPressed(){
  if (keyCode == LEFT) leftPressed = true;
  if (keyCode == RIGHT) rightPressed = true;
  if (keyCode == UP) upPressed = true;
  if (keyCode == DOWN) downPressed = true;
  if (keyCode == CONTROL) ctrlPressed = true;
  if (key == 'w' || key == 'W') wPressed = true;
  if (key == 'a' || key == 'A') aPressed = true;
  if (key == 's' || key == 'S') sPressed = true;
  if (key == 'd' || key == 'D') dPressed = true;
  if (key == 'q' || key == 'Q') qPressed = true;
  if (key == 'e' || key == 'E') ePressed = true;
  if (key == 'r' || key == 'R') setup();
 }
 
void keyReleased(){
  if (keyCode == LEFT) leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP) upPressed = false;
  if (keyCode == DOWN) downPressed = false;
  if (keyCode == CONTROL) ctrlPressed = false;
  if (key == 'w' || key == 'W') wPressed = false;
  if (key == 'a' || key == 'A') aPressed = false;
  if (key == 's' || key == 'S') sPressed = false;
  if (key == 'd' || key == 'D') dPressed = false;
  if (key == 'q' || key == 'Q') qPressed = false;
  if (key == 'e' || key == 'E') ePressed = false;
}
