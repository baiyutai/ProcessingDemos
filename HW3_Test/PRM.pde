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
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes]; // adjency table, saved for HW3_Test
float[][] edges = new float[numNodes+2][numNodes+2]; // adjency matrix

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  // build graph
  buildGraph(centers, radii, numObstacles, nodePos, numNodes);

  ArrayList<Integer> path = new ArrayList();
  // add start & goal pos as new nodes
  changeStartGoal(startPos, goalPos, centers, radii, numObstacles, nodePos, numNodes);
  // see if start->goal can be linked directly
  if (edges[numNodes][numNodes+1] >= 0)
    return path;
  // use AStar to find path
  path = runAStar(startPos, goalPos, nodePos, numNodes);
  return path;
}

// A-star
import java.util.PriorityQueue;
import java.util.Queue;
ArrayList<Integer> runAStar(Vec2 start, Vec2 goal, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  // initialize pairs
  Node[] graphNodes = new Node[numNodes+2];
  for (int i = 0; i < numNodes+2; i++)
    graphNodes[i] = new Node(i);
  // compute h(node)
  float[] h_val = new float[numNodes+2];
  for (int i = 0; i < numNodes; i++)
    h_val[i] = nodePos[i].distanceTo(goal);
  h_val[numNodes] = start.distanceTo(goal);
  h_val[numNodes+1] = 0.0;
  // initialize visited array & parentID array
  Boolean[] visited = new Boolean[numNodes+2];
  Integer[] parentID = new Integer[numNodes+2];
  for (int i = 0; i < numNodes+2; i++) {
    visited[i] = false;
    parentID[i] = -1;
  } 
  
  Queue<Node> pq = new PriorityQueue<Node>(new NodeComparator());
  Node startNode = graphNodes[numNodes];
  float g_cost = 0;
  startNode.f_val = h_val[startNode.ID] + g_cost;
  pq.add(startNode);
  
  while (!pq.isEmpty()){
    Node curNode = pq.poll();
    visited[curNode.ID] = true;
    g_cost = curNode.f_val - h_val[curNode.ID];
    
    // goal found
    if (curNode.ID == numNodes+1) break;
    
    // check neighbors of curNode
    for (int i = 0; i < numNodes+2; i++){
      if (i == curNode.ID || edges[curNode.ID][i] < 0) continue;
      Node child = graphNodes[i];
      
      // skip if the neighbor visited
      if (visited[i] == true) continue;
      
      // add if neighbor not in the priority queue
      if (!pq.contains(child)){
        child.f_val = h_val[child.ID] + g_cost + edges[curNode.ID][i];
        parentID[child.ID] = curNode.ID;
        pq.add(child);
      }
      else { // update if a better path found
        float childGCost = child.f_val - h_val[child.ID];
        if (g_cost + edges[curNode.ID][i] < childGCost) {
          parentID[child.ID] = curNode.ID;
          child.f_val = h_val[child.ID] + g_cost + edges[curNode.ID][i];
        }
      }
    }
  }
  
  Node iterNode = graphNodes[numNodes+1];
  if (parentID[iterNode.ID] == -1) {
    path.add(-1);
  }
  else {
    while (parentID[iterNode.ID] != numNodes){
      iterNode = graphNodes[parentID[iterNode.ID]];
      path.add(0, iterNode.ID);
    }
  }
  return path;
}

void buildGraph(Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  // initialize neighbors
  for (int i = 0; i < numNodes; i++)
    neighbors[i] = new ArrayList<Integer>();
  // connect neighbors
  for (int i = 0; i < numNodes; i++){
    edges[i][i] = 0;
    for (int j = i+1; j < numNodes; j++) {
      Vec2 dir = nodePos[i].minus(nodePos[j]).normalized();
      float dist = nodePos[i].distanceTo(nodePos[j]);
      hitInfo hitCircles = rayCircleListIntersect(centers, radii, numObstacles, nodePos[j], dir, dist);
      if (!hitCircles.hit) {
        neighbors[i].add(j);
        neighbors[j].add(i);
        edges[i][j] = dist;
        edges[j][i] = dist;
      }
      else {
        edges[i][j] = -1;
        edges[j][i] = -1;
      }
    }
  }
}

void changeStartGoal(Vec2 start, Vec2 goal, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  // test if start->goal can be linked directly
  Vec2 dir = goal.minus(start).normalized();
  float dist = goal.distanceTo(start);
  hitInfo hitCircles = rayCircleListIntersect(centers, radii, numObstacles, start, dir, dist);
  if (!hitCircles.hit) {
    edges[numNodes][numNodes+1] = dist;
    edges[numNodes+1][numNodes] = dist;
    return;
  }
  edges[numNodes][numNodes+1] = -1;
  edges[numNodes+1][numNodes] = -1;
  
  // add new edges with start & end
  for (int i = 0; i < numNodes; i++){
    // detect with start
    dir = nodePos[i].minus(start).normalized();
    dist = nodePos[i].distanceTo(start);
    hitCircles = rayCircleListIntersect(centers, radii, numObstacles, start, dir, dist);
    if (!hitCircles.hit) {
      edges[i][numNodes] = dist;
      edges[numNodes][i] = dist;
    }
    else {
      edges[i][numNodes] = -1;
      edges[numNodes][i] = -1;
    }
    // detect with goal
    dir = nodePos[i].minus(goal).normalized();
    dist = nodePos[i].distanceTo(goal);
    hitCircles = rayCircleListIntersect(centers, radii, numObstacles, goal, dir, dist);
    if (!hitCircles.hit) {
      edges[i][numNodes+1] = dist;
      edges[numNodes+1][i] = dist;
    }
    else {
      edges[i][numNodes+1] = -1;
      edges[numNodes+1][i] = -1;
    }
  }
}

public class Node {
  public Integer ID;
  public float f_val;
  
  public Node(int id){
    ID = id;
    f_val = 999999;
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
