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

void setup(){
  size(800, 600, P3D);
  background(255);
  texture = loadImage("texture.jpg");
  
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
Vec3 spherePos = new Vec3(400, 400, 0);

void draw(){
  update(1/frameRate);
  background(255);
  
  // draw shapes
  //for (int i = 0; i < xh-1; i++)
  //  for (int j = 0; j < yh-1; j++){
  //    beginShape();
  //    texture(texture);
  //    vertex(pos[i*yh+j].x, pos[i*yh+j].y, pos[i*yh+j].z, j*dtextW, i*dtextH);
  //    vertex(pos[i*yh+j+1].x, pos[i*yh+j+1].y, pos[i*yh+j+1].z, (j+1)*dtextW, i*dtextH);
  //    vertex(pos[(i+1)*yh+j+1].x, pos[(i+1)*yh+j+1].y, pos[(i+1)*yh+j+1].z, (j+1)*dtextW, (i+1)*dtextH);
  //    vertex(pos[(i+1)*yh+j].x, pos[(i+1)*yh+j].y, pos[(i+1)*yh+j].z, j*dtextW, (i+1)*dtextH);
  //    endShape(CLOSE);
  //  }
  for (int i = 0; i < xh-2; i++)
    for (int j = 0; j < yh-2; j++){
      beginShape();
      texture(texture);
      vertex(pos[i*yh+j].x, pos[i*yh+j].y, pos[i*yh+j].z, j*dtextW, i*dtextH);
      vertex(pos[i*yh+j+2].x, pos[i*yh+j+2].y, pos[i*yh+j+2].z, (j+2)*dtextW, i*dtextH);
      vertex(pos[(i+2)*yh+j+2].x, pos[(i+2)*yh+j+2].y, pos[(i+2)*yh+j+2].z, (j+2)*dtextW, (i+2)*dtextH);
      vertex(pos[(i+2)*yh+j].x, pos[(i+2)*yh+j].y, pos[(i+2)*yh+j].z, j*dtextW, (i+2)*dtextH);
      endShape(CLOSE);
    }
  
  // obstacle rendering, use balllit3d.pde
  pushMatrix();
  fill(#A0D6E5);
  specular(120, 120, 180);
  ambientLight(90,90,90);
  //lightSpecular(255,255,255); shininess(20);
  directionalLight(200, 200, 200, -1, 1, -1);
  translate(spherePos.x, spherePos.y, spherePos.z);
  sphere(sphereRadius);
  popMatrix();
}

// string parameters
float kd = 20, ks = 300;
float vertL0 = (downleft.x - upleft.x)/(xh-1), g = 20;
float horiL0 = upright.distanceTo(upleft) / (yh-1);
float kd_t = 0.5, ks_t = 10.0;
void update(float dt){
  // update forces
  for (int j = 0; j < yh; j++){
    for (int i = 1; i < xh; i++){
      // gravity
      acc[i*yh+j].x = 0.0; acc[i*yh+j].y = 9.8; acc[i*yh+j].z = 0.0;
      
      // vertical string forces
      Vec3 e = (pos[i*yh+j].minus(pos[(i-1)*yh+j])).normalized();
      float fs = -ks*(vertL0 - pos[i*yh+j].distanceTo(pos[(i-1)*yh+j]));
      float fd = -kd*dot(e, vel[(i-1)*yh+j].minus(vel[i*yh+j]));
      acc[(i-1)*yh+j].add(e.times(fs+fd));
      acc[i*yh+j].subtract(e.times(fs+fd));
    }
  }
  for (int i = 1; i < xh; i++)
    for (int j = 0; j < yh-1; j++){
      // horizontal string forces
      Vec3 e = pos[i*yh+j+1].minus(pos[i*yh+j]);
      float fs = -ks_t*(horiL0 - e.length());
      e.normalize();
      float fd = -kd_t*dot(e, vel[i*yh+j].minus(vel[i*yh+j+1]));
      acc[i*yh+j].add(e.times(fs+fd));
      acc[i*yh+j+1].subtract(e.times(fs+fd));
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
