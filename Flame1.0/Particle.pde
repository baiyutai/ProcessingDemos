public class Particle{
  public float lifetime, transparency, age;
  public Vec3 pos, vel, colorp;
  public float sizeStart, sizeNow;
  
  public Particle(float size, float lifetime, Vec3 pos, Vec3 vel){
    sizeStart = size;
    sizeNow = sizeStart;
    age = 0;
    transparency = 1.0;
    colorp = new Vec3(0.0,0.0,0.0);
    
    this.lifetime = lifetime;
    this.pos = pos;
    this.vel = vel;
  }
  
  public boolean IsAlive(){ return (lifetime > age); }
  
  public void Update(float dt){
    // update age and position
    age += dt;
    pos.add(vel.times(dt));
    
    // define transparency, update particle size
    // transparency = 1.0/(1.0+0.03*(age-lifetime)^2)
    float transparency = 1.0/(1.0 + 0.03*(age-lifetime/2)*(age-lifetime/2));
    sizeNow = sizeStart * transparency;
    
    // update particle color
    // dist = distance(this.position, fire_startup_center = (0.0, 0.0, 0.0))
    float dist = pos.length();
    colorp.x = 255.0;
    colorp.y = 255.0*(1-dist/40);
    colorp.z = 255.0*(1-dist/20);
  }
}
