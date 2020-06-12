float radius = 10;
float theta = 0.0, cameraRadius = 500.0, ptheta = 0.0;
float phi, pPhi;
int maxNumParticles = 10000, numParticles = 0;
float rminParticle = 0.1, rmaxParticle = 1.0;
float lifeminParticle = 2, lifemaxParticle = 10;
float velminParticle = -5, velmaxParticle = -8;
Particle particles[] = new Particle[maxNumParticles];

//Setup is called once
void setup() {
  size(300, 600, P3D); noStroke(); //600x600 3D win
  theta = 0.0; cameraRadius = 500.0;
  phi = PI/2; sphereDetail(5);
} 

float genRate = 3000;
void update(float dt){
  float toGen = genRate * dt;
  float fracPart = toGen - int(toGen);
  if (random(1) < fracPart) toGen = int(toGen) + 1;
  else toGen = int(toGen);
  int i = 0;
  while (i < numParticles){
    if (particles[i].IsAlive()) i += 1;
    else {
      particles[i] = particles[numParticles-1];
      numParticles -= 1;
    }
  }
  for (i = 0; i < toGen; ++i){
    if (numParticles >= maxNumParticles) break;
    float tempR = random(1)*radius;
    float tempTheta = random(1)*PI*2;
    Vec3 pos = new Vec3(tempR*cos(tempTheta),0,tempR*sin(tempTheta));
    Vec3 vel = new Vec3(0.0,velminParticle+random(1)*(velmaxParticle-velminParticle),0.0);
    particles[numParticles] = new Particle(rminParticle+random(1)*(rmaxParticle - rminParticle), 
                                           lifeminParticle+random(1)*(lifemaxParticle - lifeminParticle), pos, vel);
    numParticles += 1;
  }
  for (i = 0; i < numParticles; ++i){ particles[i].Update(dt); }
}


//Draw is called every frame
void draw() {
  update(1.0/frameRate);
  
  background(0);  //White background
  
  camera(cos(theta)*cameraRadius*sin(phi), cos(phi)*cameraRadius, -sin(theta)*cameraRadius*sin(phi),
         0.0, 0.0, 0.0,
         0.0, 1.0, 0.0);
  
  //fill(240,70,30, 100);          //Green material
  //specular(120, 120, 180);  //Setup lights… 
  //ambientLight(90,90,90);   //More light… (environmental)
  //lightSpecular(255,255,255); shininess(20);  //More light…
  //directionalLight(200, 200, 200, -1, 1, -1); //More light…
  //translate(300,position);
  for (int i = 0; i < numParticles; ++i){
    pushMatrix();
    translate(particles[i].pos.x, particles[i].pos.y, particles[i].pos.z);
    fill(particles[i].r, particles[i].g, particles[i].b, particles[i].transparency*255);
    sphere(particles[i].size);
    popMatrix();
  }
  //sphere(radius);   //Draw sphere
}

float preMouseX=0.0, preMouseY=0.0;
void mousePressed(){
  preMouseX = mouseX; preMouseY = mouseY;
  ptheta = theta;
  pPhi = phi;
}

void mouseDragged(){
  theta = ptheta + 3*(mouseX - preMouseX)/cameraRadius;
  phi = pPhi + 3*(mouseY - preMouseY)/cameraRadius;
}

void mouseWheel(MouseEvent event){
  cameraRadius += 3*event.getCount();
}
  
