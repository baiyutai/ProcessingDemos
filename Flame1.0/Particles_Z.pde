float radius = 10; // fire range
float theta = 0.0, cameraRadius = 200.0, phi = PI/2; // camera parameters

// particle parameters
int maxNumParticles = 10000, numParticles = 0, genRate = 3000;
float sizeMin = 0.1, sizeMax = 1.0;
float lifeMin = 1, lifeMax = 5;
float velMin = -5, velMax = -8;
Particle particles[] = new Particle[maxNumParticles];

void setup() {
  size(300, 600, P3D); noStroke(); //300x600 3D window
} 

void update(float dt){
  int toGen = (int)(genRate * dt);
  if (random(1) < genRate * dt - toGen) toGen++;
  
  // move dead particles to the end of the array
  // decrease the length of the array
  int i = 0;
  while (i < numParticles){
    if (particles[i].IsAlive()) i++;
    else particles[i] = particles[--numParticles];
  }
  
  // generate new particles
  for (i = numParticles; i < toGen + numParticles && i < maxNumParticles; ++i){
    float sampleR = sampling(0, radius), sampleTheta = sampling(0, PI*2);
    // Particle(size, lifetime, position, velocity)
    particles[i] = new Particle(sampling(sizeMin, sizeMax), 
                                sampling(lifeMin, lifeMax),
                                new Vec3(sampleR*cos(sampleTheta),0,sampleR*sin(sampleTheta)),
                                new Vec3(0, sampling(velMin, velMax), 0));
  }
  numParticles = min(numParticles + toGen, maxNumParticles);
  
  // update each particle
  for (i = 0; i < numParticles; ++i){ particles[i].Update(dt); }
}


//Draw is called every frame
void draw() {
  update(1.0/frameRate);
  background(0); // black background
  camera(cos(theta)*cameraRadius*sin(phi), cos(phi)*cameraRadius, -sin(theta)*cameraRadius*sin(phi),
         0.0, 0.0, 0.0,
         0.0, 1.0, 0.0);
  // draw particles
  for (int i = 0; i < numParticles; ++i){
    pushMatrix();
    translate(particles[i].pos.x, particles[i].pos.y, particles[i].pos.z);
    fill(particles[i].colorp.x, particles[i].colorp.y, particles[i].colorp.z, particles[i].transparency*255);
    box(particles[i].sizeNow);
    popMatrix();
  }
}

// parameters used to save the previous condition
float preMouseX, preMouseY, pPhi, pTheta;

// save states
void mousePressed(){
  preMouseX = mouseX; preMouseY = mouseY;
  pTheta = theta;
  pPhi = phi;
}

// move camera position on a sphere surface
void mouseDragged(){
  theta = pTheta - 3*(mouseX - preMouseX)/cameraRadius;
  phi = pPhi + 3*(mouseY - preMouseY)/cameraRadius;
  phi = min(max(phi, 0.001), PI-0.001);  // clamp phi, set the border condition experimentally
}

// change distance(camera, fire center) by mousewheel
void mouseWheel(MouseEvent event){
  cameraRadius += 3*event.getCount();
}

float sampling(float a, float b){
 return random(b-a)+a;
}
  
