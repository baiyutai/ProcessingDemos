// boids parameters
static int numMax = 900;
int numBoids;
float genRate;
Boid[] boids = new Boid[numMax];

// camera parameters
Vec3 cameraPos, cameraDir;
float cameraAngle;

void setup(){
  size(1920,1080,P3D);
  // camera initialization
  cameraPos = new Vec3(-138.7, -33.5, 71.51);
  cameraAngle = -0.42079687;
  cameraDir = new Vec3(cos(cameraAngle),0,sin(cameraAngle));
  // boids initialization
  numBoids = 0;
  genRate = 20.0;
}

void update(float dt){
  // generate new boids
  int numToGen = (int)(genRate * dt);
  if (random(1) < genRate * dt - numToGen) numToGen++;
  for (int i = numBoids; i < numBoids + numToGen && i < numMax; ++i){
    boids[i] = new Boid();
  }
  numBoids += numToGen;
  if (numBoids > numMax) numBoids = numMax;
  // delete dead boids
  int i = 0;
  while (i < numBoids){
    if (boids[i].IsAlive()) i++;
    else {
      boids[i] = boids[numBoids-1];
      numBoids--;
    }
  }
}

void draw(){
  cameraUpdate(0.5);
  update(1/frameRate);
  //println(frameRate);
  
  // background initialization
  background(255);
  camera(cameraPos.x,cameraPos.y, cameraPos.z,
  cameraPos.x+cameraDir.x, cameraPos.y+cameraDir.y, cameraPos.z+cameraDir.z,
  0.0,1.0,0.0);
  noStroke();
  
  // plot a tree
  pushMatrix();
  translate(0,20,0);
  fill(142,60,19);
  box(20,80,20);
  popMatrix();
  pushMatrix();
  translate(0,-20,0);
  fill(59,142,19);
  sphere(28);
  popMatrix();
  
  // plot the ground
  fill(240,181,92);
  beginShape();
  vertex(1000,60,1000);
  vertex(1000,60,-1000);
  vertex(-1000,60,-1000);
  vertex(-1000,60,1000);
  endShape(CLOSE);
  
  // update and plot boids
  stroke(1);
  for (int i = 0; i < numBoids; ++i){
    boids[i].FlockBehavior(boids, numBoids);
    boids[i].Update(1/frameRate);
    boids[i].Show();
  }
}

// control camera according to keyboard and mouse inputs
void cameraUpdate(float step){
  if (upPressed) cameraPos.y -= step;
  if (downPressed) cameraPos.y += step;
  if (leftPressed) cameraAngle -= step/10;
  if (rightPressed) cameraAngle += step/10;
  cameraDir.x = cos(cameraAngle);
  cameraDir.z = sin(cameraAngle);
}

boolean leftPressed, rightPressed, upPressed, downPressed;
void keyPressed(){
  if (keyCode == LEFT) leftPressed = true;
  if (keyCode == RIGHT) rightPressed = true;
  if (keyCode == UP) upPressed = true;
  if (keyCode == DOWN) downPressed = true;
  if (key == 'r') setup();
 }
 
void keyReleased(){
  if (keyCode == LEFT) leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP) upPressed = false;
  if (keyCode == DOWN) downPressed = false;
}

void mouseWheel(MouseEvent event){
  cameraPos.add(cameraDir.times(-3*event.getCount()));
}
