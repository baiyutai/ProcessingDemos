// initialize cloth parameters
int xh = 51, yh = 51;
Vec3[] pos = new Vec3[xh * yh];
Vec3[] vel = new Vec3[xh * yh];
Vec3[] acc = new Vec3[xh * yh];
Vec3 upleft = new Vec3(200, 100, 100);
Vec3 upright = new Vec3(300, 100, -100);
Vec3 downleft = new Vec3(500, 100, 100);

void setup(){
  size(800, 600, P3D);
  background(255);
  
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
}

// obstacle parameters
int sphereRadius = 100;
Vec3 spherePos = new Vec3(400, 400, 0);

void draw(){
  update(1/frameRate);
  background(255);
  
  // draw ropes
  stroke(120);
  for (int j = 0; j < yh; j++)
    for (int i = 0; i < xh-1; i++){
      line(pos[i*yh+j].x, pos[i*yh+j].y, pos[i*yh+j].z,
           pos[(i+1)*yh+j].x, pos[(i+1)*yh+j].y, pos[(i+1)*yh+j].z);
    }
  
  // obstacle rendering, use balllit3d.pde
  pushMatrix();
  fill(#A0D6E5);
  specular(120, 120, 180);
  ambientLight(90,90,90);
  //lightSpecular(255,255,255); shininess(20);
  directionalLight(200, 200, 200, -1, 1, -1);
  noStroke();
  translate(spherePos.x, spherePos.y, spherePos.z);
  sphere(sphereRadius);
  popMatrix();
}

// string parameters
float kd = 20, ks = 500;
float rest_len = (downleft.x - upleft.x)/(xh-1), g = 20;
void update(float dt){
  // update forces
  for (int j = 0; j < yh; j++){
    for (int i = 1; i < xh; i++){
      // gravity
      acc[i*yh+j].x = 0.0; acc[i*yh+j].y = 9.8; acc[i*yh+j].z = 0.0;
      
      // string forces
      Vec3 e = (pos[i*yh+j].minus(pos[(i-1)*yh+j])).normalized();
      float fs = -ks*(rest_len - pos[i*yh+j].distanceTo(pos[(i-1)*yh+j]));
      float fd = -kd*dot(e, vel[(i-1)*yh+j].minus(vel[i*yh+j]));
      acc[(i-1)*yh+j].add(e.times(fs+fd));
      acc[i*yh+j].subtract(e.times(fs+fd));
    }
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
      if (pos[i*yh+j].distanceTo(spherePos) < sphereRadius + 0.09){
        Vec3 n = (pos[i*yh+j].minus(spherePos)).normalized();
        pos[i*yh+j] = spherePos.plus(n.times(sphereRadius + 0.09));
        vel[i*yh+j].times(-1.0);
      }
    }
  }
}
