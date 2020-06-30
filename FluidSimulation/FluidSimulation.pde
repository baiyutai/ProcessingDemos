// initialize box parameters
float widthBox = 300, depthBox = 500, heightBox = 250;
Vec3 posBox = new Vec3(400, 325, 0);
Vec3 oposBox = new Vec3(posBox.x-widthBox/2, posBox.y+heightBox/2, posBox.z-depthBox/2);

// initialize fluid parameters
int xnum = 100, znum = 100;
float[] h = new float[xnum * znum];
float dx = widthBox / xnum, dz = depthBox/znum;

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
      h[i*znum + k] = heightBox/2.0;
}

void draw(){
  // camera & background settings
  update(1/frameRate);
  background(0);
  cameraUpdate(0.05);
  camera(cameraPos.x,cameraPos.y, cameraPos.z,
  cameraPos.x+cameraDir.x, cameraPos.y+cameraDir.y, cameraPos.z+cameraDir.z,
  0.0,1.0,0.0);
  pointLight(250, 250, 250, 550, 100, 36);
  ambientLight(150,150,150);
  
  // render water
  noStroke();
  fill(#2270D3);
  for (int i = 0; i < xnum; i++)
    for (int k = 0; k < znum; k++){
      pushMatrix();
      translate((i+0.5)*dx+oposBox.x, oposBox.y-h[i*znum+k]/2.0, (k+0.5)*dz+oposBox.z);
      box(dx, h[i*znum+k], dz);
      popMatrix();
    }
  
  // render a box
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
  if (upPressed) phi += step;
  if (downPressed) phi -= step;
  if (leftPressed) theta -= step;
  if (rightPressed) theta += step;
  cameraDir.x = cos(theta)*sin(phi);
  cameraDir.y = cos(phi);
  cameraDir.z = sin(theta)*sin(phi);
}

boolean leftPressed, rightPressed, upPressed, downPressed;
void keyPressed(){
  if (keyCode == LEFT) leftPressed = true;
  if (keyCode == RIGHT) rightPressed = true;
  if (keyCode == UP) upPressed = true;
  if (keyCode == DOWN) downPressed = true;
 }
 
void keyReleased(){
  if (keyCode == LEFT) leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP) upPressed = false;
  if (keyCode == DOWN) downPressed = false;
}

void mouseWheel(MouseEvent event){
  cameraPos.add(cameraDir.times(-10*event.getCount()));
}
