// initialize cloth parameters
int xh = 41, yh = 41;
Vec3[] pos = new Vec3[xh * yh];
Vec3[] vel = new Vec3[xh * yh];
Vec3[] acc = new Vec3[xh * yh];
Vec3 upleft = new Vec3(200, 100, 100);
Vec3 upright = new Vec3(300, 100, -100);
Vec3 downleft = new Vec3(500, 100, 100);
PImage texture;
float textW = 226, textH = 300;
float dtextW = textW / (yh-1), dtextH = textH / (xh-1);

// camera parameters
Vec3 cameraPos, cameraDir;
float theta, phi;
void setup(){
  size(800, 600, P3D);
  background(255);
  texture = loadImage("texture.jpg");
  
  // camera initialization
  cameraPos = new Vec3(400, 300, 600);
  theta = -PI/2; phi = PI/2;
  cameraDir = new Vec3(cos(theta)*sin(phi),cos(phi),sin(theta)*sin(phi));
  
  // initialize cloth parameters
  Vec3 zero = new Vec3(0,0,0);
  for (int i = 0; i < xh; i++)
    for (int j = 0; j < yh; j++) {
      pos[i*yh+j] = new Vec3(upleft.x, upleft.y, upleft.z);
      pos[i*yh+j].add(interpolate(zero, upright.minus(upleft), float(j)/(yh-1)));
      pos[i*yh+j].add(interpolate(zero, downleft.minus(upleft), float(i)/(xh-1)));
      vel[i*yh+j] = new Vec3(0.0, 0.0, 0.0);
      acc[i*yh+j] = new Vec3(0.0, 0.0, 0.0);
    }
  noStroke();
}

// obstacle parameters
int sphereRadius = 100;
Vec3 spherePos = new Vec3(400, 350, 0);

void draw(){
  println(frameRate);
  cameraUpdate(0.05);
  obstacleUpdate(5.0);
  for (int t = 0; t < frameRate; t++)
    update(1.0/500);
  
  background(255);
  camera(cameraPos.x,cameraPos.y, cameraPos.z,
  cameraPos.x+cameraDir.x, cameraPos.y+cameraDir.y, cameraPos.z+cameraDir.z,
  0.0,1.0,0.0);
  directionalLight(180, 180, 180, -1, 1, -1);
  ambientLight(150,150,150);
  
  for (int i = 0; i < xh-1; i++)
    for (int j = 0; j < yh-1; j++){
      beginShape();
      texture(texture);
      vertex(pos[i*yh+j].x, pos[i*yh+j].y, pos[i*yh+j].z, j*dtextW, i*dtextH);
      vertex(pos[i*yh+j+1].x, pos[i*yh+j+1].y, pos[i*yh+j+1].z, (j+1)*dtextW, i*dtextH);
      vertex(pos[(i+1)*yh+j+1].x, pos[(i+1)*yh+j+1].y, pos[(i+1)*yh+j+1].z, (j+1)*dtextW, (i+1)*dtextH);
      vertex(pos[(i+1)*yh+j].x, pos[(i+1)*yh+j].y, pos[(i+1)*yh+j].z, j*dtextW, (i+1)*dtextH);
      endShape(CLOSE);
    }
  
  // obstacle rendering, use balllit3d.pde
  pushMatrix();
  fill(#A0D6E5);
  specular(120, 120, 180);
  translate(spherePos.x, spherePos.y, spherePos.z);
  sphere(sphereRadius);
  popMatrix();
}

// string parameters
float kd = 50, ks = 200;
float vertL0 = downleft.distanceTo(upleft)/(xh-1), g = 5.0;
float horiL0 = upright.distanceTo(upleft) / (yh-1);
float kd_t = 40, ks_t = 200;
float k_aero = 0.001;
void update(float dt){
  // update forces
  for (int i = 0; i < xh; i++)
   for (int j = 0; j < yh; j++){
     acc[i*yh+j].x = 0.0;
     acc[i*yh+j].y = g;
     acc[i*yh+j].z = 0.0;
   }
  for (int j = 0; j < yh; j++){
    for (int i = 1; i < xh; i++){
      // vertical string forces
      Vec3 e = pos[i*yh+j].minus(pos[(i-1)*yh+j]);
      float fs = -ks*(vertL0 - e.length());
      e.normalize();
      float fd = -kd*(dot(e, vel[(i-1)*yh+j])-dot(e,vel[i*yh+j]));
      e.mul(fs+fd);
      acc[(i-1)*yh+j].add(e);
      acc[i*yh+j].subtract(e);
    }
  }
  for (int i = 1; i < xh; i++)
    for (int j = 0; j < yh-1; j++){
      // horizontal string forces
      Vec3 e = pos[i*yh+j+1].minus(pos[i*yh+j]);
      float fs = -ks_t*(horiL0 - e.length());
      e.normalize();
      float fd = -kd_t*(dot(e, vel[i*yh+j])-dot(e,vel[i*yh+j+1]));
      acc[i*yh+j].add(e.times(fs+fd));
      acc[i*yh+j+1].subtract(e.times(fs+fd));
    }
  // air drag forces
  for (int i = 0; i < xh-1; i++)
    for (int j = 0; j < yh-1; j++){
    Vec3 v_avg, n_star, acc_avg;
    
    // triangle 1
    v_avg = (vel[i*yh+j].plus(vel[i*yh+j+1])).plus(vel[(i+1)*yh+j]);
    v_avg.mul(1.0/3);
    n_star = cross(pos[i*yh+j+1].minus(pos[i*yh+j]), pos[(i+1)*yh+j].minus(pos[i*yh+j]));
    acc_avg = n_star.times(-0.5*k_aero*v_avg.length()*dot(v_avg, n_star)/2/n_star.length());
    acc_avg.mul(1.0/3);
    acc[i*yh+j].add(acc_avg);
    acc[i*yh+j+1].add(acc_avg);
    acc[(i+1)*yh+j].add(acc_avg);
    
    // triangle 2
    v_avg = (vel[(i+1)*yh+j+1].plus(vel[i*yh+j+1])).plus(vel[(i+1)*yh+j]);
    v_avg.mul(1.0/3);
    n_star = cross(pos[i*yh+j+1].minus(pos[(i+1)*yh+j+1]), pos[(i+1)*yh+j].minus(pos[(i+1)*yh+j+1]));
    acc_avg = n_star.times(-0.5*k_aero*v_avg.length()*dot(v_avg, n_star)/2/n_star.length());
    acc_avg.mul(1.0/3);
    acc[(i+1)*yh+j+1].add(acc_avg);
    acc[i*yh+j+1].add(acc_avg);
    acc[(i+1)*yh+j].add(acc_avg);
    
    // triangle 3
    v_avg = (vel[(i+1)*yh+j].plus(vel[i*yh+j])).plus(vel[(i+1)*yh+j+1]);
    v_avg.mul(1.0/3);
    n_star = cross(pos[i*yh+j].minus(pos[(i+1)*yh+j]), pos[(i+1)*yh+j+1].minus(pos[(i+1)*yh+j]));
    acc_avg = n_star.times(-0.5*k_aero*v_avg.length()*dot(v_avg, n_star)/2/n_star.length());
    acc_avg.mul(1.0/3);
    acc[(i+1)*yh+j].add(acc_avg);
    acc[i*yh+j].add(acc_avg);
    acc[(i+1)*yh+j+1].add(acc_avg);
    
    // triangle 4
    v_avg = (vel[i*yh+j+1].plus(vel[i*yh+j])).plus(vel[(i+1)*yh+j+1]);
    v_avg.mul(1.0/3);
    n_star = cross(pos[i*yh+j].minus(pos[i*yh+j+1]), pos[(i+1)*yh+j+1].minus(pos[i*yh+j+1]));
    acc_avg = n_star.times(-0.5*k_aero*v_avg.length()*dot(v_avg, n_star)/2/n_star.length());
    acc_avg.mul(1.0/3);
    acc[i*yh+j+1].add(acc_avg);
    acc[i*yh+j].add(acc_avg);
    acc[(i+1)*yh+j+1].add(acc_avg);
    }
  
  
  // update velocities and positions
  for (int j = 0; j < yh; j++){
    for (int i = 1; i < xh; i++){
      vel[i*yh+j].add(acc[i*yh+j].times(dt));
      pos[i*yh+j].add(vel[i*yh+j].times(dt));
    }
  }
  
  // collision detect
  for (int j = 0; j < yh; j++){
    for (int i = 1; i < xh; i++){
      if (pos[i*yh+j].distanceTo(spherePos) < sphereRadius + 2.0){
        Vec3 n = (pos[i*yh+j].minus(spherePos)).normalized();
        pos[i*yh+j] = spherePos.plus(n.times(sphereRadius + 2.0));
        vel[i*yh+j].times(-1.0);
      }
    }
  }
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

//control obstacle
void obstacleUpdate(float step){
  Vec3 addPos = new Vec3(0,0,0);
  if (wPressed) addPos.y -= 1.0;
  if (sPressed) addPos.y += 1.0;
  if (aPressed) addPos.x -= 1.0;
  if (dPressed) addPos.x += 1.0;
  if (qPressed) addPos.z -= 1.0;
  if (ePressed) addPos.z += 1.0;
  if (addPos.length()>0.5){
    addPos.normalize();
    spherePos.add(addPos.times(step));
  }
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

void mouseWheel(MouseEvent event){
  cameraPos.add(cameraDir.times(-10*event.getCount()));
}
