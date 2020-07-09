//You will only be turning in this file
//Your solution will be graded based on it's runtime (smaller is better), 
//the optimality of the path you return (shorter is better), and the
//number of collisions along the path (it should be 0 in all cases).

//You must provide a function with the following prototype:
// ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes);
// Where: 
//    -startPos and goalPos are 2D start and goal positions
//    -centers and radii are arrays specifying the center and radius
//    -numObstacles specifies the number of obstacles
//    -nodePos is an array specifying the 2D position of roadmap nodes
//    -numNodes specifies the number of roadmap nodes
// The function should return an ArrayList of node IDs (indexes into the nodePos array).
// This should provide a collision-free chain of direct paths from the start position
// to the position of each node, and finally to the goal position.
// If there is no collision-free path between the start and goal, return an ArrayList with
// the 0'th element of "-1".

// Your code can safely make the following assumptions:
//   - The variable maxNumNodes has been defined as a large static int, and it will
//     always be bigger than the numNodes variable passed into planPath()
//   - None of position in the nodePos array will be inside an obstacle
//   - The start and the goal position will never be inside an obstacle
Node[] graphNodes = new Node[maxNumNodes+2];
Boolean[] visited = new Boolean[maxNumNodes+2];

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  buildGraph(startPos, goalPos, centers, radii, numObstacles, nodePos, numNodes);
  path = runAStar(graphNodes, numNodes+2, numNodes, numNodes+1);
  
  return path;
}

//UCS (Uniform cost search)
import java.util.PriorityQueue;
import java.util.Queue;
ArrayList<Integer> runAStar(Node[] graphNodes, int numNodes, int startID, int goalID){
  for (int i = 0; i < numNodes; i++) visited[i] = false;
  
  Queue<Node> pq = new PriorityQueue<Node>(new NodeComparator());
  Node start = graphNodes[startID];
  float g_cost = 0;
  start.f_val = start.h_val + g_cost;
  pq.add(start);
  
  while (!pq.isEmpty()){
    Node curNode = pq.poll();
    visited[curNode.ID] = true;
    g_cost = curNode.f_val - curNode.h_val;
    
    // goal found
    if (curNode.ID == goalID) break;
    
    // check neighbors of curNode
    for (int i = 0; i < curNode.neighborNum; i++){
      Integer childID = curNode.neighborID[i];
      float edgeCost = curNode.neighborDist[i];
      Node child = graphNodes[curNode.neighborID[i]];
      
      // skip if the neighbor is already visited
      if (visited[childID] == true) continue;
      
      if (!pq.contains(child)){
        child.f_val = child.h_val + g_cost + edgeCost;
        child.parentID = curNode.ID;
        pq.add(child);
      }
      else {
        float childCost = child.f_val - child.h_val;
        if (g_cost + edgeCost < childCost) {
          child.parentID = curNode.ID;
          child.f_val = child.h_val + g_cost + edgeCost;
        }
      }
    }
  }
  
  ArrayList<Integer> path = new ArrayList();
  Node iterNode = graphNodes[goalID];
  if (iterNode.parentID == -1) {
    path.add(-1);
  }
  else {
    while (iterNode.parentID != startID){
      iterNode = graphNodes[iterNode.parentID];
      path.add(0, iterNode.ID);
    }
  }
  return path;
}

void buildGraph(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  // initialize a temporary nodepos array, add start & goal
  Vec2[] tempNodePos = new Vec2[numNodes+2];
  for (int i = 0; i < numNodes; i++)
    tempNodePos[i] = nodePos[i];
  tempNodePos[numNodes] = startPos;
  tempNodePos[numNodes+1] = goalPos;
  // compute h(node) = distance(node, goal)
  for (int i = 0; i < numNodes+2; i++){
    graphNodes[i] = new Node();
    graphNodes[i].ID = i;
    graphNodes[i].h_val = tempNodePos[i].distanceTo(goalPos);
  }
  // connect neighbors
  for (int i = 0; i < numNodes+2; i++)
    for (int j = i+1; j < numNodes+2; j++) {
      Vec2 dir = tempNodePos[i].minus(tempNodePos[j]).normalized();
      float dist = tempNodePos[i].distanceTo(tempNodePos[j]);
      hitInfo hitCircles = rayCircleListIntersect(centers, radii, numObstacles, tempNodePos[j], dir, dist);
      if (!hitCircles.hit) {
        graphNodes[i].add(j, dist);
        graphNodes[j].add(i, dist);
      }
    }
}

public class Node {
  public Integer ID, parentID;
  public float h_val;
  public float f_val;
  public Integer neighborNum;
  public Integer[] neighborID = new Integer[maxNumNodes+1];
  public float[] neighborDist = new float[maxNumNodes+1];
  
  public Node(){
    h_val = 0;
    f_val = 999999;
    neighborNum = 0;
    parentID = -1;
  }
  
  public void add(int targetID, float targetDist){
    neighborID[neighborNum] = targetID;
    neighborDist[neighborNum] = targetDist;
    neighborNum++;
  }
}

import java.util.Comparator;
class NodeComparator implements Comparator<Node>{
  public int compare(Node a, Node b){
    if (a.f_val > b.f_val) return 1;
    if (a.f_val == b.f_val) return 0;
    return -1;
  }
}
