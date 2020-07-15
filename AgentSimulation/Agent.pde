class Agent{
  Vec2 pos;
  float rad;
  int maxGoals = 20, numGoals = 0, firstGoal = 0;
  Vec2[] goals = new Vec2[maxGoals];
  
  Agent(Vec2 position, float radius){
    pos = new Vec2(position.x, position.y);
    rad = radius;
  }
  
  boolean addGoal(Vec2 newGoal){
    if (numGoals == maxGoals) return false;
    goals[(firstGoal+numGoals)%maxGoals] = new Vec2(newGoal.x, newGoal.y);
    numGoals++;
    return true;
  }
  
  void step(float stepLen){
    if (numGoals == 0) return;
    
    Vec2 goalPos = goals[firstGoal];
    Vec2 vel = goalPos.minus(pos).normalized();
    float dist = goalPos.distanceTo(pos);
    // if reach the goal, move it from the list
    if (dist < stepLen) {
      pos.x = goalPos.x;
      pos.y = goalPos.y;
      firstGoal = (firstGoal+1) % maxGoals;
      numGoals--;
    }
    else{
      pos.add(vel.times(stepLen));
    }
  }
    
  void display(){
    pushMatrix();
    translate(pos.x, pos.y, 0);
    sphere(rad);
    popMatrix();
  }
}
