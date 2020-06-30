// initialize box parameters
float widthBox = 300, depthBox = 300, heightBox = 250;
Vec3 posBox = new Vec3(400, 325, 0);

// initialize fluid parameters
int xnum = 51, znum = 51;
float[] h = new float[xnum * znum];
float dx = widthBox / (xnum-1), dz = depthBox/(znum-1);
float[] posx = new float[xnum];
float bottomY = posBox.y + heightBox/2;
float[] posz = new float[znum];

// camera parameters
Vec3 cameraPos, cameraDir;
float theta, phi;
void setup(){
  size(800, 600, P3D);
  background(0);

  // camera initialization
  cameraPos = new Vec3(400, 300, 600);
  theta = -PI/2; phi = PI/2;
  cameraDir = new Vec3(cos(theta)*sin(phi),cos(phi),sin(theta)*sin(phi));
  
  // water initialization
  for (int i = 0; i < xnum; i++)
    for (int k = 0; k < znum; k++)
      h[k*xnum + i] = (1-float(i+k)/(xnum+znum))*heightBox;
  // positions initialization
  posx[0] = posBox.x-widthBox/2;
  for (int i = 1; i < xnum; i++)
    posx[i] = posx[i-1] + dx;
  posz[0] = posBox.z-depthBox/2;
  for (int k = 1; k < znum; k++)
    posz[k] = posz[k-1] + dz;
}

void draw(){
  // camera & background settings
  update(1/frameRate);
  background(0);
  cameraUpdate(0.05);
  camera(cameraPos.x,cameraPos.y, cameraPos.z,
  cameraPos.x+cameraDir.x, cameraPos.y+cameraDir.y, cameraPos.z+cameraDir.z,
  0.0,1.0,0.0);
  lightSpecular(255,255,255); shininess(20);
  pointLight(250, 250, 250, 550, 100, 36);
  ambientLight(100, 100, 100);
  
  // render water
  noStroke();
  fill(#2270D3);
  for (int i = 0; i < xnum-1; i++)
    for (int k = 0; k < znum-1; k++){
      beginShape();
      vertex(posx[i], bottomY-h[k*xnum+i], posz[k]);
      vertex(posx[i], bottomY-h[(k+1)*xnum+i], posz[k+1]);
      vertex(posx[i+1], bottomY-h[(k+1)*xnum+i+1], posz[k+1]);
      vertex(posx[i+1], bottomY-h[k*xnum+i+1], posz[k]);
      endShape(CLOSE);
    }
    
  // render bottom
  beginShape();
  vertex(posx[0], bottomY, posz[0]);
  vertex(posx[xnum-1], bottomY, posz[0]);
  vertex(posx[xnum-1], bottomY, posz[znum-1]);
  vertex(posx[0], bottomY, posz[znum-1]);
  endShape(CLOSE);
  
  // render surrounding surfaces
  // further opposite
  beginShape();
  vertex(posx[xnum-1], bottomY, posz[0]);
  vertex(posx[0], bottomY, posz[0]);
  for (int i = 0; i < xnum; i++)
    vertex(posx[i], bottomY-h[i], posz[0]);
  endShape(CLOSE);
  // left side
  beginShape();
  vertex(posx[0], bottomY, posz[znum-1]);
  vertex(posx[0], bottomY, posz[0]);
  for (int k = 0; k < znum; k++)
    vertex(posx[0], bottomY-h[k*xnum], posz[k]);
  endShape(CLOSE);
  // right side
  beginShape();
  vertex(posx[xnum-1], bottomY, posz[znum-1]);
  vertex(posx[xnum-1], bottomY, posz[0]);
  for (int k = 0; k < znum; k++)
    vertex(posx[xnum-1], bottomY-h[k*xnum+xnum-1], posz[k]);
  endShape(CLOSE);
  // closer opposite
  beginShape();
  vertex(posx[xnum-1], bottomY, posz[znum-1]);
  vertex(posx[0], bottomY, posz[znum-1]);
  for (int i = 0; i < xnum; i++)
    vertex(posx[i], bottomY-h[(znum-1)*xnum+i], posz[znum-1]);
  endShape(CLOSE);
  
  // render box
  stroke(255);
  noFill();
  pushMatrix();
  translate(posBox.x, posBox.y, posBox.z);
  box(widthBox, heightBox, depthBox);
  popMatrix();
}

void update(float dt){
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

boolean leftPressed, rightPressed, upPressed, downPressed, ctrlPressed;
void keyPressed(){
  if (keyCode == LEFT) leftPressed = true;
  if (keyCode == RIGHT) rightPressed = true;
  if (keyCode == UP) upPressed = true;
  if (keyCode == DOWN) downPressed = true;
  if (keyCode == CONTROL) ctrlPressed = true;
 }
 
void keyReleased(){
  if (keyCode == LEFT) leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP) upPressed = false;
  if (keyCode == DOWN) downPressed = false;
  if (keyCode == CONTROL) ctrlPressed = false;
}

void mouseWheel(MouseEvent event){
  cameraPos.add(cameraDir.times(-10*event.getCount()));
}
