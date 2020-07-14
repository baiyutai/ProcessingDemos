float[][] edges = new float[numNodes+2][numNodes+2]; // adjency matrix

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos,
                            Vec2[] centers, float[] radii, int numCircle,
                            Vec2[] boxTopLeft, float[] boxW, float[] boxH, int numBox,
                            Vec2[] nodePos, int numNodes){
  // build graph
  buildGraph(centers, radii, numCircle,
             boxTopLeft, boxW, boxH, numBox,
             nodePos, numNodes);

  ArrayList<Integer> path = new ArrayList();
  // add start & goal pos as new nodes
  addNewNode(startPos, centers, radii, numCircle, boxTopLeft, boxW, boxH, numBox, nodePos, numNodes);
  addNewNode(goalPos, centers, radii, numCircle, boxTopLeft, boxW, boxH, numBox, nodePos, numNodes+1);
  // see if start->goal can be linked directly
  if (edges[numNodes][numNodes+1] >= 0)
    return path;
  // use AStar to find path
  path = runAStar(numNodes, numNodes+1, nodePos, numNodes+2);
  return path;
}

// A-star
import java.util.PriorityQueue;
import java.util.Queue;
ArrayList<Integer> runAStar(int startID, int goalID, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  Vec2 goal = nodePos[goalID];
  
  // initialize pairs
  Node[] graphNodes = new Node[numNodes];
  for (int i = 0; i < numNodes; i++)
    graphNodes[i] = new Node(i);
    
  // compute h(node)
  float[] h_val = new float[numNodes];
  for (int i = 0; i < numNodes; i++)
    h_val[i] = nodePos[i].distanceTo(goal);
    
  // initialize visited array & parentID array
  Boolean[] visited = new Boolean[numNodes+2];
  Integer[] parentID = new Integer[numNodes+2];
  for (int i = 0; i < numNodes+2; i++) {
    visited[i] = false;
    parentID[i] = -1;
  } 
  
  Queue<Node> pq = new PriorityQueue<Node>(new NodeComparator());
  Node startNode = graphNodes[startID];
  float g_cost = 0;
  startNode.f_val = h_val[startNode.ID] + g_cost;
  pq.add(startNode);
  
  while (!pq.isEmpty()){
    Node curNode = pq.poll();
    visited[curNode.ID] = true;
    g_cost = curNode.f_val - h_val[curNode.ID];
    
    // goal found
    if (curNode.ID == goalID) break;
    
    // check neighbors of curNode
    for (int i = 0; i < numNodes; i++){
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
  
  Node iterNode = graphNodes[goalID];
  if (parentID[iterNode.ID] == -1) {
    path.add(-1);
  }
  else {
    while (parentID[iterNode.ID] != startID){
      iterNode = graphNodes[parentID[iterNode.ID]];
      path.add(0, iterNode.ID);
    }
  }
  return path;
}

void buildGraph(Vec2[] centers, float[] radii, int numCircle,
                Vec2[] boxTopLeft, float[] boxW, float[] boxH, int numBox,
                Vec2[] nodePos, int numNodes){
  // connect neighbors
  for (int i = 0; i < numNodes; i++){
    edges[i][i] = 0;
    for (int j = i+1; j < numNodes; j++) {
      Vec2 dir = nodePos[i].minus(nodePos[j]).normalized();
      float dist = nodePos[i].distanceTo(nodePos[j]);
      hitInfo hitCircles = rayCircleListIntersect(centers, radii, numCircle, nodePos[j], dir, dist);
      hitInfo hitBoxes = rayBoxListIntersect(boxTopLeft, boxW, boxH, numBox, nodePos[j], dir, dist);
      if (!hitCircles.hit && !hitBoxes.hit) {
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

void addNewNode(Vec2 newNode,
                Vec2[] centers, float[] radii, int numCircle,
                Vec2[] boxTopLeft, float[] boxW, float[] boxH, int numBox,
                Vec2[] nodePos, int numNodes){
  // add new edges with original nodes
  for (int i = 0; i < numNodes; i++){
    // detect with start
    Vec2 dir = nodePos[i].minus(newNode).normalized();
    float dist = nodePos[i].distanceTo(newNode);
    hitInfo hitCircles = rayCircleListIntersect(centers, radii, numCircle, newNode, dir, dist);
    hitInfo hitBoxes = rayBoxListIntersect(boxTopLeft, boxW, boxH, numBox, newNode, dir, dist);
    if (!hitCircles.hit && !hitBoxes.hit) {
      edges[i][numNodes] = dist;
      edges[numNodes][i] = dist;
    }
    else {
      edges[i][numNodes] = -1;
      edges[numNodes][i] = -1;
    }
  }
  // add edge with itself
  edges[numNodes][numNodes] = 0;
  // add node itself
  nodePos[numNodes] = new Vec2(newNode.x, newNode.y);
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
