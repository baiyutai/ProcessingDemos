// 3D Vector Library
// use course materials in CSCI 5611 as reference

public class Vec3 {
  public float x, y, z;
  
  public Vec3(float x, float y, float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public float length(){
    return sqrt(x*x+y*y+z*z);
  }
  
  public void add(Vec3 rhs){
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }
  
  public Vec3 times(float rhs){
    return new Vec3(rhs*x, rhs*y, rhs*z);
  }
  
  public float distanceTo(Vec3 rhs){
    float dx = x - rhs.x;
    float dy = y - rhs.y;
    float dz = z - rhs.z;
    return sqrt(dx*dx + dy*dy + dz*dz);
  }
}
