public class Boid{
  Vec3 position, velocity, acceleration;
  float maxVel, maxAcc;
  
  public Boid(){
    maxVel = 8;
    maxAcc = 0.6;
    this.position = new Vec3(random(-50)-50,random(-50)-20,random(-50)-50);
    this.velocity = new Vec3(random(maxVel), 0.0, random(maxVel));
    this.acceleration = new Vec3();
  }
  
  // anticipated position
  public Vec3 posAnti(float time){
    return position.plus(velocity.times(time));
  }
  
  public boolean IsAlive(){
    if (this.position.y > 60.0 - 3.0) return false; // fall on the ground
    if (this.position.distanceTo(new Vec3(0,-20,0)) < 28 + 3.0) return false; // collision with the tree
    return true;
  }
  
  // force for avoiding falling
  public Vec3 AvoidGround(){
    float groundHeight = 60.0, time = 10.0;
    Vec3 posAnti = posAnti(time);
    Vec3 acc = new Vec3();
    if (posAnti.y > groundHeight) {
      acc.y = -maxAcc;
      acc.limit(maxAcc);
    }
    return acc;
  }
  
  // force for avoiding collision
  public Vec3 AvoidTree(){
    float time = 5.0;
    Vec3 posAnti = posAnti(time);
    Vec3 acc = new Vec3();
    Vec3 velAvoid = cross(velocity, new Vec3(0,-1,0)).normalized();
    velAvoid.mul(maxVel);
    if (posAnti.distanceTo(new Vec3(0,-20,0)) < 28) acc = velAvoid.minus(velocity);
    acc.limit(maxAcc);
    return acc;
  }
  
  // alignment steer
  public Vec3 Alignment(Boid[] boids, int numBoids){
    float distDetect = 15.0;
    Vec3 velAlign = new Vec3();
    int numAligned = 0;
    for (int i = 0; i < numBoids; ++i){
      float dist = boids[i].position.distanceTo(position);
      if (dist < distDetect && boids[i] != this){
        velAlign.add(boids[i].velocity);
        numAligned += 1;
      }
    }
    Vec3 accAlign = new Vec3();
    if (numAligned > 0 && velAlign.length() > 0.1){
      velAlign.normalize();
      velAlign.mul(maxVel);
      accAlign = velAlign.minus(this.velocity);
      accAlign.limit(maxAcc);
    }
    return accAlign;
  }
  
  // cohesion steer
  public Vec3 Cohesion(Boid[] boids, int numBoids){
    float distDetect = 15.0;
    Vec3 posAvg = new Vec3();
    int numAvg = 0;
    for (int i = 0; i < numBoids; ++i){
      float dist = boids[i].position.distanceTo(position);
      if (dist < distDetect && boids[i] != this){
        posAvg.add(boids[i].position);
        numAvg += 1;
      }
    }
    Vec3 velCoh = new Vec3(), accCoh = new Vec3();
    if (numAvg > 0){
      posAvg.mul(1.0/numAvg);
      velCoh = posAvg.minus(this.position);
      velCoh.normalize();
      velCoh.mul(maxVel);
      accCoh = velCoh.minus(this.velocity);
      accCoh.limit(maxAcc);
    }
    return accCoh;
  }
  
  // seperation steer
  public Vec3 Seperation(Boid[] boids, int numBoids){
    float distDetect = 5.0;
    Vec3 velSep = new Vec3();
    int numSep = 0;
    for (int i = 0; i < numBoids; ++i){
      float dist = boids[i].position.distanceTo(this.position);
      if (dist < distDetect && boids[i] != this){
        Vec3 vel = position.minus(boids[i].position);
        vel.mul(1.0/dist/dist);
        velSep.add(vel);
        numSep += 1;
      }
    }
    Vec3 accSep = new Vec3();
    if (numSep > 0){
      velSep.normalize();
      velSep.mul(maxVel);
      accSep = velSep.minus(this.velocity);
      accSep.limit(maxAcc);
    }
    return accSep;
  }
  
  // combine all the steers and forces
  public void FlockBehavior(Boid[] boids, int numBoids){
    acceleration.add(Alignment(boids, numBoids));
    acceleration.add(Cohesion(boids, numBoids));
    acceleration.add(Seperation(boids, numBoids).times(1.5));
    acceleration.add(AvoidGround().times(1.5));
    acceleration.add(AvoidTree().times(1.5));
  }
  
  // move forward
  public void Update(float dt){
    position.add(velocity.times(dt));
    velocity.add(acceleration.times(dt));
    velocity.limit(maxVel);
    acceleration.mul(0);
  }
  
  public void Show(){
    pushMatrix();
    translate(position.x, position.y, position.z);
    fill(255);
    drawBoid(velocity,3.0);
    popMatrix();
  }
}

void drawBoid(Vec3 velocity, float size){
  // dirHead, dirRise, dirWing together group a local x-y-z coordinate
  Vec3 dirHead = velocity.normalized();
  Vec3 dirCamera = new Vec3(0,-1,0); // used to define dirRise
  Vec3 dirRise = dirCamera.minus(projAB(dirCamera, dirHead));
  dirRise.normalize();
  Vec3 dirWing = cross(dirHead, dirRise);
  
  // plot two triangles making the combination looks like a bird
  dirRise.mul(size/2);
  dirWing.mul(size);
  
  // wings triangle
  beginShape();
  vertex(dirHead.x,dirHead.y,dirHead.z);
  vertex(-dirWing.x, -dirWing.y, -dirWing.z);
  vertex(dirWing.x, dirWing.y, dirWing.z);
  endShape(CLOSE);
  
  // body triangle
  beginShape();
  vertex(dirHead.x,dirHead.y,dirHead.z);
  vertex(0, 0, 0);
  vertex(-dirRise.x,-dirRise.y,-dirRise.z);
  endShape(CLOSE);
}
