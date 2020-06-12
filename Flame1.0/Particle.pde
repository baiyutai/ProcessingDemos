public class Particle{
  public float size, lifetime, transparency, age;
  public Vec3 pos;
  public Vec3 vel;
  public float o_size;
  public float r,g,b;
  
  public Particle(float size, float lifetime, Vec3 pos, Vec3 vel){
    this.o_size = size;
    this.size = size;
    this.lifetime = lifetime;
    this.age = 0;
    this.pos = pos;
    this.vel = vel;
    this.transparency = 1.0;
    this.r = 0.0;
    this.g = 0.0;
    this.b = 0.0;
  }
  
  public boolean IsAlive(){ return (lifetime > age); }
  
  public void Update(float dt){
    float transparency = 1.0/(1.0 + (age-lifetime/2)*(age-lifetime/2));
    age += dt;
    size = o_size * transparency;
    //r = 255 * transparency;
    //transparency = 1.0/(1.0 + 3*(-pos.y-0.01)*(-pos.y-0.01));
    //g = 255 * transparency;
    //transparency = 1.0/(1.0 + 7*(-pos.y-0.01)*(-pos.y-0.01));
    //b = 255 * transparency;
    //transparency = 1.0/(1.0 + (age-lifetime/2)*(age-lifetime/2));
    pos.add(vel.times(dt));
    float dist = pos.length();
    //r = 255.0;
    //g = 255.0;
    //b = 255.0;
    r = 255.0;
    g = 255.0*(1-dist/40);
    b = 255.0*(1-dist/20);
  }
  
  public float ToDist(Vec3 pos){
    return this.pos.distanceTo(pos);
  }
}
