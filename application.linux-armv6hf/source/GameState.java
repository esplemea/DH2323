import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import java.util.HashSet; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GameState extends PApplet {


static final boolean SPHERES = false;
// -----------------------------------------------------------------
float eyeX, eyeY, eyeZ;
float angUD = 0.1f;
float angLR = 0.1f;
int d = 1000;
// -----------------------------------------------------------------

final static PVector AXIS_OBJECT3D = new PVector(0, -1, 0);
final static PVector ORIGIN_OBJECT3D = new PVector(0, 0, 0);
static final int THRESHOLD_COLLIDE_AGAIN_OBJECTS = 2;//re-check the same item in one frame after a collision
static final int WALL_SIZE = 500;
static final float EPSILON_COLLISION_TRIANGLE = 0.01f;
static final float OVER_BACKTRACKING_TRIANGLE = 10f;
static final float DISTANCE_MIN_SPHERE_COLLIDERS = 2;
static final int MAX_ITER = 10;
static long lastTime = 0;
static boolean mouseClicked = false;
static Set<Object3D> roomObjects;

PImage bground;
int k = 0;
String[] balloonNames = new String[]{"ballon-stripped-centered.obj", "ballon-stripped-centered-blue.obj", "ballon-stripped-centered-green.obj", "ballon-stripped-centered-orange.obj", "ballon-stripped-centered-purple.obj"};

static List<Object3D> mObjects;
PShape balloon;
List<PShape> balloons;
PShape wall;
PShape roofWall;

public void addObject3D(Object3D toAdd)
{
  mObjects.add(toAdd);
}

public void removeObject3D(Object3D toRemove)
{
  mObjects.remove(toRemove);
}

public void settings() {
  size(1000, 1000, P3D);
}

public void setup() {
  bground = loadImage("vaporwave.png");
  roomObjects = new HashSet();
  bground.resize(width,height);
  background(bground);

  eyeX = (width/2)-d*(sin(radians(angLR)));
  eyeY = (height/2)-d*(sin(radians(angUD)));
  eyeZ = d*cos(radians(angUD))*cos(radians(angLR));

  noStroke();
  balloon = loadShape("ballon-stripped-centered.obj");
  balloons = new ArrayList<PShape>();
  for (int i = 0; i < balloonNames.length; ++i) {
    balloons.add(loadShape(balloonNames[i]));
  }

  wall = createShape();
  wall.beginShape();
  wall.noStroke();
  wall.fill(200, 200, 255, 100);

  wall.beginShape();
  wall.vertex(WALL_SIZE/2, WALL_SIZE/2, 0);
  wall.vertex(WALL_SIZE/2, -WALL_SIZE/2, 0);
  wall.vertex(-WALL_SIZE/2, -WALL_SIZE/2, 0);

  wall.vertex(WALL_SIZE/2, WALL_SIZE/2, 0);
  wall.vertex(-WALL_SIZE/2, WALL_SIZE/2, 0);
  wall.vertex(-WALL_SIZE/2, -WALL_SIZE/2, 0);
  wall.endShape();

  roofWall = createShape();
  roofWall.beginShape();
  roofWall.noStroke();
  roofWall.fill(210, 210, 210, 100);
  roofWall.vertex(WALL_SIZE/2, 0, 0);
  roofWall.vertex(-WALL_SIZE/2, 0, 0);
  roofWall.vertex(0, -WALL_SIZE/2, WALL_SIZE/2);
  roofWall.endShape();

  mObjects = new ArrayList<Object3D>();

  if (SPHERES) {
    Object3D o1 = new Object3D(new PVector(120f, 130f, 0), false, 10, 0.169f, 0.5f, new PVector(0, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0));
    o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 65, o1));
    mObjects.add(o1);
  } else {

    mObjects.add(createDefaultBalloon(new PVector(-130, 130f, 0)));
    mObjects.add(createDefaultBalloon(new PVector(0, 130f, 0)));
    mObjects.add(createDefaultBalloon(new PVector(150, 130f, 0)));

    mObjects.add(createDefaultBalloon(new PVector(0, 400f, -150)));
    mObjects.add(createDefaultBalloon(new PVector(-30, 550f, 20)));
    mObjects.add(createDefaultBalloon(new PVector(-60, 700f, 20)));
    mObjects.add(createDefaultBalloon(new PVector(-90, 850f, 20)));
    mObjects.add(createDefaultBalloon(new PVector(-120, 1000f, 20)));

    mObjects.add(createDefaultBalloon(new PVector(30, 400f, 170)));
    mObjects.add(createDefaultBalloon(new PVector(60, 550f, 170)));
    mObjects.add(createDefaultBalloon(new PVector(90, 700f, 170)));
    mObjects.add(createDefaultBalloon(new PVector(120, 850f, 170)));
    mObjects.add(createDefaultBalloon(new PVector(150, 1000f, 170)));
  }
  /*Object3D o1 = new Object3D(new PVector(120f, 130f, 0), false, 10, 0.169f, 0.9f, new PVector(0, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0));
   o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 30, o1));
   o1.setShape(balloon);
   mObjects.add(o1);*/

  PVector position = new PVector(0, 0, 0);
  PVector rotation = new PVector(0, 0.5f, 0);
  createRoom(position, rotation);

  println("setup");
}

// Update is called once per frame
public void draw () {
  background(bground);
  //directionalLight(255, 255, 255, 0.1, -0.6, -0.3);
  //ambientLight(102,102,102);
  lights();

  // CAMERA:
  boolean gamePaused = false;
  if (keyPressed && key == CODED && keyCode == 17) {
    float x = (width/2)-d*(sin(0.01f))*cos(-PI/2 + 0.01f);
    float y = (height/2)-d*(sin(-PI/2 + 0.01f)) + 0.1f;
    float z = d*cos(-PI/2 + 0.01f)*cos(0.01f);
    camera(x, y, z, 
      width/2, height/2, 0, 
      0, 1, 0);
    gamePaused = true;
  } else {
    if (eyeZ<0) {
      camera(eyeX, eyeY, eyeZ, 
        width/2, height/2, 0, 
        0, -1, 0);
    } else {
      camera(eyeX, eyeY, eyeZ, 
        width/2, height/2, 0, 
        0, 1, 0);
    }
  }
  
  translate(width/2, height/2, 0); //centering

  if (gamePaused && mouseClicked) {
    print("pressed");

    destroyRoom();

    if (SPHERES) {
      Object3D o1 = new Object3D(new PVector(mouseX*0.8f - 400, 350, -mouseY*0.8f + 400), false, 10, 0.169f, 0.5f, new PVector(0, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0));
      o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 65, o1));
      mObjects.add(o1);
    } else {
      mObjects.add(createDefaultBalloon(new PVector(mouseX*0.8f - 400, 350, -mouseY*0.8f + 400)));
    }

    destroyRoom();
    PVector position = new PVector(0, 0, 0);
    PVector rotation = new PVector(0, 0.5f, 0);
    createRoom(position, rotation);
  }
  mouseClicked = false;

  

  long newTime = System.currentTimeMillis();
  float dt = ((float)(newTime - lastTime))/1000;
  lastTime = newTime;
  if (!gamePaused) {
    for (Object3D o : mObjects)
    {
      if (dt < 1)
        o.Update(dt);
    }

    int nbObjects = mObjects.size();
    Set<Integer> collided = new HashSet();
    for (int i = 0; i< nbObjects; ++i)
      collided.add(i);
    recurCollisions(collided, 0);
  }

  for (Object3D o : mObjects) {
    pushMatrix();
    translate(o.getPosition());
    rotateX(o.getRot().x);
    rotateY(o.getRot().y);
    rotateZ(o.getRot().z);
    PShape toDraw = o.getShape();
    if (toDraw == null)
      sphere(o.getSphereCollider().getRadius());
    else
      shape(toDraw);
    popMatrix();
  }
  println("DRAW OPS TOTAL TIME: "+(System.currentTimeMillis()-newTime)+"ms");
  /*
  directionalLight(50, 100, 125, 0, 1, 0);
   //ambientLight(102, 102, 102);
   ambientLight(255, 255, 255);
   background(200, 200, 200);
   fill(74, 178, 118, 80);
   sphere(30);
   shape(balloon);*/
}

public void mouseClicked() {
  mouseClicked = true;
}

public void recurCollisions(Set<Integer> collided, int iter) {
  if (iter == THRESHOLD_COLLIDE_AGAIN_OBJECTS)
    return;
  Set<Integer> nextCollided = new HashSet();
  int size = mObjects.size();
  for (Integer i : collided) {
    for (int j = 0; j < size; ++j) {
      SphereCollider s1 = mObjects.get(i).getSphereCollider();
      SphereCollider s2 = mObjects.get(j).getSphereCollider();
      if (collides(s1, s2)) {
        nextCollided.add(i);
        nextCollided.add(j);
        break;
      }
    }
  }
  recurCollisions(nextCollided, ++iter);
}

public boolean collides(SphereCollider s1, SphereCollider s2)
{
  if (s1.isRoot() && s2.isRoot())
  {
    if (s1.getTriangles() != null && s2.getTriangles() != null)
      return false;
    else if (s1.getTriangles() != null) {
      goThroughVerticesCollision(s2, s1.getTriangles());
    } else if (s2.getTriangles() != null) {
      goThroughVerticesCollision(s1, s2.getTriangles());
    } else if (s1.isColliding(s2)) {
      PVector oldPos1 = s1.getAbsolutePosition(true);
      PVector newPos1 = s1.getAbsolutePosition(false);
      PVector oldPos2 = s2.getAbsolutePosition(true);
      PVector newPos2 = s2.getAbsolutePosition(false);
      PVector v1 = PVector.sub(newPos1, oldPos1);
      PVector v2 = PVector.sub(newPos2, oldPos2);

      float distance = s1.getRadius() + s2.getRadius();
      if (PVector.sub(oldPos1, oldPos2).mag() < distance) {
        //println("Objects inside on another!");
        return false;
      }
      float t = findT(distance, oldPos1, oldPos2, v1, v2, 0, 1, 0);

      //println("distance min "+distance+" real distance "+PVector.sub(PVector.add(oldPos1, PVector.mult(v1, t)), PVector.add(oldPos2, PVector.mult(v2, t))).mag());

      //Move the objects backward
      Object3D o1 = s1.getParent();
      PVector oldPos = o1.getOldPosition();
      PVector pos1 = PVector.add(oldPos, PVector.sub(o1.getPosition(), oldPos).mult(t));
      o1.setPosition(pos1);
      o1.setRot(PVector.add(o1.getOldRot(), PVector.sub(o1.getRot(), o1.getOldRot()).mult(t)));

      Object3D o2 = s2.getParent();
      oldPos = o2.getOldPosition();
      PVector pos2 = PVector.add(oldPos, PVector.sub(o2.getPosition(), oldPos).mult(t));
      o2.setPosition(pos2);
      o2.setRot(PVector.add(o2.getOldRot(), PVector.sub(o2.getRot(), o2.getOldRot()).mult(t)));



      //bouncing
      float speed1 = o1.getVelocity().mag();
      float speed2 = o2.getVelocity().mag();
      float mass1 = o1.getMass();
      float mass2 = o2.getMass();
      float bounce = o1.getBounce() * o2.getBounce();
      PVector dir = PVector.sub(pos1, pos2).normalize();

      if (!o1.isFloating()) {
        float velocity1 = (bounce*mass2*(speed2 - speed1) + mass1 * speed1 + mass2 * speed2)/(mass1 + mass2);
        log("v1 "+velocity1);
        o1.setVelocity(PVector.mult(dir, velocity1), s1.getPosition());
      }
      if (!o2.isFloating()) {
        float velocity2 = (bounce*mass1*(speed1 - speed2) + mass1 * speed1 + mass2 * speed2)/(mass1 + mass2); //<>//
        o2.setVelocity(PVector.mult(dir, -velocity2), s2.getPosition());
      }
      return true;
    }
    return false;
  } else if (s1.isRoot())
  {
    return goThroughCollider(s2, s1);
  } else if (s2.isRoot())
  {
    return goThroughCollider(s1, s2);
  }
  if (s1.getChildren().size() > s2.getChildren().size()) {
    return goThroughCollider(s2, s1);
  }
  return goThroughCollider(s1, s2);
}

public float findT(float distance, PVector oldPos1, PVector oldPos2, PVector v1, PVector v2, float tmin, float tmax, int maxIter) {
  if (maxIter == MAX_ITER) {
    return tmin;
  }
  float t = tmin + (tmax-tmin)/2;
  PVector newDistance = PVector.sub(PVector.add(oldPos1, PVector.mult(v1, t)), PVector.add(oldPos2, PVector.mult(v2, t)));
  if (newDistance.x*newDistance.x + newDistance.y*newDistance.y + newDistance.z*newDistance.z < distance*distance) //<>//
    return findT(distance, oldPos1, oldPos2, v1, v2, tmin, t, ++maxIter);
  else if (newDistance.mag() < distance + DISTANCE_MIN_SPHERE_COLLIDERS) //<>//
    return t;
  else
    return findT(distance, oldPos1, oldPos2, v1, v2, t, tmax, ++maxIter);
}

public boolean goThroughCollider(SphereCollider toGoThrough, SphereCollider s1)
{
  for (SphereCollider s : toGoThrough.getChildren())
  {
    boolean exit = collides(s1, s);
    if (exit)
      return true;
  }
  return false;
}

public void translate(PVector p) {
  translate(p.x, p.y, p.z);
} //<>//

public Object3D createDefaultBalloon(PVector position) { //<>//
  //volumic mass 0.169 is for heliumy
  Object3D o1 = new Object3D(position, false, 10, 0.169f, 0.5f, new PVector(0, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0), 130, 0.7f);
  o1.setShape(balloons.get(new Random().nextInt(balloons.size())));

  Set<SphereCollider> mChildren = new HashSet();
  mChildren.add(new SphereCollider(new PVector(0, -15, 0), 50, o1));
  mChildren.add(new SphereCollider(new PVector(0, 39, 0), 25, o1));
  mChildren.add(new SphereCollider(new PVector(6, 26, 0), 30, o1));
  mChildren.add(new SphereCollider(new PVector(-3, 26, -5.2f), 30, o1));
  mChildren.add(new SphereCollider(new PVector(-3, 26, 5.2f), 30, o1));
  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 65, o1, mChildren));

  return o1;
}

//Create default square shaped wall of size 500x500
public Object3D createWall(PVector position, PVector rot) {
  Object3D o1 = new Object3D(position, false, 0, 0, 1, new PVector(0, 0, 0), new PVector(0, 0, 0), rot);
  float radius = (float)(Math.pow(WALL_SIZE*WALL_SIZE/2, 0.5f));

  Set<Triangle> mVertices = new HashSet();
  mVertices.add(new Triangle(new PVector(WALL_SIZE/2, WALL_SIZE/2, 0), new PVector(WALL_SIZE/2, -WALL_SIZE/2, 0), new PVector(-WALL_SIZE/2, -WALL_SIZE/2, 0), o1));
  mVertices.add(new Triangle(new PVector(WALL_SIZE/2, WALL_SIZE/2, 0), new PVector(-WALL_SIZE/2, WALL_SIZE/2, 0), new PVector(-WALL_SIZE/2, -WALL_SIZE/2, 0), o1)); //<>//

  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), radius, mVertices, o1)); //<>// //<>//
  o1.setShape(wall);
  return o1; //<>//
}

//Create default square shaped wall of size 500x500
public Object3D createRoofWall(PVector position, PVector rot) {
  Object3D o1 = new Object3D(position, false, 0, 0, 1, new PVector(0, 0, 0), new PVector(0, 0, 0), rot);
  float radius = (float)(Math.pow(WALL_SIZE*WALL_SIZE/2, 0.5f));

  Set<Triangle> mVertices = new HashSet();
  mVertices.add(new Triangle(new PVector(WALL_SIZE/2, 0, 0), new PVector(-WALL_SIZE/2, 0, 0), new PVector(0, -WALL_SIZE/2, WALL_SIZE/2), o1));

  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), radius, mVertices, o1)); //<>//
  o1.setShape(roofWall);
  return o1;
}
 //<>//
//Create default square shaped wall of size 500x500 //<>//
public void createRoom(PVector position, PVector rot) {
  Object3D current = createWall(position.copy().add(new PVector(0, 0, -WALL_SIZE/2)), new PVector(0, 0, 0));
  roomObjects.add(current);
  mObjects.add(current);
  current = createWall(position.copy().add(new PVector(0, 0, WALL_SIZE/2)), new PVector(0, 0, 0));
  roomObjects.add(current);
  mObjects.add(current);
  current = (createWall(position.copy().add(new PVector(-WALL_SIZE/2, 0, 0)), new PVector(0, PI/2, 0)));
  roomObjects.add(current);
  mObjects.add(current);
  current = (createWall(position.copy().add(new PVector(WALL_SIZE/2, 0, 0)), new PVector(0, PI/2, 0)));
  roomObjects.add(current);
  mObjects.add(current);

  current = (createRoofWall(position.copy().add(new PVector(0, -WALL_SIZE/2, -WALL_SIZE/2)), new PVector(0, 0, 0)));
  roomObjects.add(current);
  mObjects.add(current);
  current = (createRoofWall(position.copy().add(new PVector(0, -WALL_SIZE/2, WALL_SIZE/2)), new PVector(0, PI, 0)));
  roomObjects.add(current);
  mObjects.add(current);
  current = (createRoofWall(position.copy().add(new PVector(-WALL_SIZE/2, -WALL_SIZE/2, 0)), new PVector(0, PI/2, 0)));
  roomObjects.add(current);
  mObjects.add(current);
  current = (createRoofWall(position.copy().add(new PVector(WALL_SIZE/2, -WALL_SIZE/2, 0)), new PVector(0, -PI/2, 0)));
  roomObjects.add(current);
  mObjects.add(current);
}

public void destroyRoom() {
  mObjects.removeAll(roomObjects);
  roomObjects.clear();
}

public void log(String message) {
  //println(System.currentTimeMillis() +" "+ message);
}

public String PVectorToString(PVector p) { 
  return "PVector("+p.x+","+p.y+","+p.z+")";
}

//matrix is 3x3
public PMatrix3D toMatrix(float[][] matrix) {
  return new PMatrix3D(matrix[0][0], matrix[0][1], matrix[0][2], 0, 
    matrix[1][0], matrix[1][1], matrix[1][2], 0, 
    matrix[2][0], matrix[2][1], matrix[2][2], 0, 
    0, 0, 0, 1);
}
//<>//
public boolean goThroughVerticesCollision(SphereCollider s, Set<Triangle> vertices) {
  for (Triangle v : vertices) { //<>// //<>// //<>//
    if (isCollidingSurface(s, v))
      return true;
  }
  for (Triangle v : vertices) {
    if (isCollidingEdges(s, v))
      return true;
  }
  return false;
}

public void setNewCenter(Object3D parent, PVector absoluteCenterCollider, PVector newCenter) {
  parent.setPosition(PVector.add(newCenter, PVector.sub(parent.getPosition(), absoluteCenterCollider)));
} //<>//

//the object containing the Vertice v is considered as floating, hence no mass, moving or backtracking!
public boolean isCollidingSurface(SphereCollider s, Triangle v) {
  PVector[] vertices = v.getAbsolutePosition(false); //<>//
  PVector center = s.getAbsolutePosition(false); //<>//

  PVector v1v2 = PVector.sub(vertices[1], vertices[0]);
  PVector v1v3 = PVector.sub(vertices[2], vertices[0]);
  //PVector v2v3 = PVector.sub(vertices[2], vertices[1]);
  PVector normal = v1v2.cross(v1v3).normalize();
  float c = -(normal.x*vertices[0].x+normal.y*vertices[0].y+normal.z*vertices[0].z);
  float radius = s.getRadius();

  //log("center "+center+" normal "+normal+" c "+c);
  float distance = Math.abs(normal.dot(center) + c);
  //log("distance "+distance+" radius "+radius);
  if (distance > radius) {
    return false;
  }

  PVector oldCenter = s.getAbsolutePosition(true); //<>//
  PVector velocity = PVector.sub(center, oldCenter);
  float t0 = (radius - Math.abs((normal.dot(oldCenter) + c)))/normal.dot(velocity);
  if (t0 > 1 + OVER_BACKTRACKING_TRIANGLE || t0 < 0 - OVER_BACKTRACKING_TRIANGLE)
    return false;
  PVector intersection = PVector.sub(oldCenter, normal).add(PVector.mult(velocity, t0));


  if (checkPointInTriangle(intersection, vertices[0], vertices[1], vertices[2], normal)) {
    log("intersect surface");
    PVector newCenter = PVector.add(oldCenter, PVector.mult(velocity, t0));
    Object3D parent = s.getParent();
    log("old pos "+center+" new pos "+newCenter);
    setNewCenter(parent, center, newCenter);

    PVector newVelocity = PVector.sub(velocity, PVector.mult(normal, 2*normal.dot(velocity)));
    newVelocity = PVector.mult(newVelocity.normalize(), parent.getVelocity().mag() * parent.getBounce() * v.getParent().getBounce());
    log("oldVelocity "+parent.getVelocity()+" new vel "+newVelocity);
    parent.setVelocity(newVelocity, s.getPosition());

    if (t0 >= 0 && t0 <= 1)
      parent.setRot(PVector.add(parent.getOldRot(), PVector.sub(parent.getRot(), parent.getOldRot()).mult(t0)));

    return true;
  }

  return false;
}

public boolean isCollidingEdges(SphereCollider s, Triangle v) {
  PVector[] vertices = v.getAbsolutePosition(false);
  PVector center = s.getAbsolutePosition(false);
  PVector v1v2 = PVector.sub(vertices[1], vertices[0]);
  PVector v1v3 = PVector.sub(vertices[2], vertices[0]);
  PVector v2v3 = PVector.sub(vertices[2], vertices[1]);
  float radius = s.getRadius(); //<>//


  //check for each of the 3 edges that the point is inside of them
  if (checkPointInSegmentAndReplace(vertices[0], vertices[1], center, v1v2, radius, s, v)) {
    return true;
  }
  if (checkPointInSegmentAndReplace(vertices[1], vertices[2], center, v2v3, radius, s, v)) {
    return true;
  }
  if (checkPointInSegmentAndReplace(vertices[0], vertices[2], center, v1v3, radius, s, v)) {
    return true;
  }

  //check for each of the 3 vertices
  for (int i = 0; i < 3; ++i) {
    PVector cp = PVector.sub(vertices[i], center);
    if (cp.x*cp.x + cp.y*cp.y + cp.z*cp.z <= radius * radius) {
      log("intersect vertex "+i);

      PVector interCenter = PVector.sub(center, vertices[i]).normalize();
      PVector newPos = PVector.add(vertices[i], PVector.mult(interCenter, radius));
      Object3D parent = s.getParent();
      log("old pos "+center+" new pos "+newPos);
      setNewCenter(parent, center, newPos);

      PVector velocity = parent.getVelocity();
      PVector newVelocity = PVector.sub(velocity, PVector.mult(interCenter, 2*interCenter.dot(velocity)));
      newVelocity = PVector.mult(newVelocity, parent.getBounce() * v.getParent().getBounce());
      parent.setVelocity(newVelocity, s.getPosition());
      log("oldVelocity "+velocity+" new vel "+newVelocity);

      return true;
    }
  } //<>// //<>//
  return false;
}

public boolean checkPointInTriangle(PVector p, PVector a, PVector b, PVector c, PVector normal) {
  float t = (normal.x*(a.x - p.x) + normal.y*(a.y - p.y) + normal.z*(a.z - p.z))/(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
  PVector proj = PVector.add(p, PVector.mult(normal, t));
  PVector aproj = PVector.sub(a, proj);
  PVector bproj = PVector.sub(b, proj);
  PVector cproj = PVector.sub(c, proj);
  float totalArea = (aproj.cross(bproj).mag() + aproj.cross(cproj).mag() + bproj.cross(cproj).mag())/2;
  float triangleArea = PVector.sub(b, a).cross(PVector.sub(c, a)).mag()/2;
  return totalArea - EPSILON_COLLISION_TRIANGLE <= triangleArea;
}

//p is the center to project on line ab and check if between them
public boolean checkPointInSegmentAndReplace(PVector a, PVector b, PVector p, PVector ab, float radius, SphereCollider s, Triangle v) {
  PVector nab = ab.normalize();
  //float c = -(nab.x*p.x+nab.y*p.y+nab.z*p.z);
  float t = (nab.x*(p.x - a.x) + nab.y*(p.y - a.y) + nab.z*(p.z - a.z))/(nab.x * nab.x + nab.y * nab.y + nab.z * nab.z);
  PVector intersection = PVector.add(a, PVector.mult(nab, t));
  PVector interP = PVector.sub(p, intersection);

  if (interP.x*interP.x + interP.y*interP.y + interP.z*interP.z > radius * radius)
    return false;

  boolean output = false;
  if (ab.x != 0) {
    if (ab.x > 0 ? (intersection.x >= a.x && intersection.x <= b.x) : (intersection.x <= a.x && intersection.x >= b.x)) {
      output = true;
    }
  } else if (ab.y != 0) {
    if (ab.y > 0 ? (intersection.y >= a.y && intersection.y <= b.y) : (intersection.y <= a.y && intersection.y >= b.y)) {
      output = true;
    }
  } else {
    if (ab.z > 0 ? (intersection.z >= a.z && intersection.z <= b.z) : (intersection.z <= a.z && intersection.z >= b.z)) {
      output = true;
    }
  }

  if (output) {
    log("intersect edge");

    interP = interP.normalize();
    PVector newPos = PVector.add(intersection, PVector.mult(interP, radius));
    Object3D parent = s.getParent();
    log("old pos "+p+" new pos "+newPos);
    setNewCenter(parent, p, newPos);

    PVector velocity = parent.getVelocity();
    PVector newVelocity = PVector.sub(velocity, PVector.mult(interP, 2*interP.dot(velocity)));
    newVelocity = PVector.mult(newVelocity, parent.getBounce() * v.getParent().getBounce());
    parent.setVelocity(newVelocity, s.getPosition());
    log("oldVelocity "+velocity+" new vel "+newVelocity);
  }

  return output;
}

public String arrayToString(float[] array) {
  String out ="[";
  for (int i = 0; i< array.length; ++i)
    out+=array[i]+",";
  return out + "]";
}

public void keyPressed() {
  switch(key) {
    // Move camera
  case CODED:
    if (keyCode == UP) {
      angUD += 5;
    }
    if (keyCode == DOWN) {
      angUD -= 5;
    }
    if (keyCode == LEFT) {
      angLR += 5;
    }
    if (keyCode == RIGHT) {
      angLR -= 5;
    }

    break;

  default:
    break;
  } // switch

  if (angUD>=360)
    angUD=0;
  if (angLR>=360)
    angLR=0;
  eyeX = (width/2)-d*(sin(radians(angLR)))*cos(radians(angUD));
  eyeY = (height/2)-d*(sin(radians(angUD)));
  eyeZ = d*cos(radians(angUD))*cos(radians(angLR));
  println("angUDle "+angUD+": "+eyeX+" / "+eyeY+" / "+eyeZ);
}

//project a point on a line
public PVector projectPointOnLine(PVector point, PVector line, PVector pointLine) { 
  float t = (line.x*(point.x - pointLine.x) + line.y*(point.y - pointLine.y) + line.z*(point.z - pointLine.z))/(line.x * line.x + line.y * line.y + line.z * line.z);
  return PVector.add(pointLine, PVector.mult(line, t));
}

public PVector rot(PVector rot, PVector toRot) {
  float x = rot.x;
  float y = rot.y;
  float z = rot.z;

  float[][] matrixX = new float[3][3];
  matrixX[0] = new float[]{1, 0, 0, 0};
  matrixX[1] = new float[]{0, cos(x), -sin(x), 0};
  matrixX[2] = new float[]{0, sin(x), cos(x), 0};


  float[][] matrixY = new float[3][3];
  matrixY[0] = new float[]{ cos(y), 0, sin(y)};
  matrixY[1] = new float[]{0, 1, 0};
  matrixY[2] = new float[]{-sin(y), 0, cos(y)};


  float[][] matrixZ = new float[3][3];
  matrixZ[0] = new float[]{cos(z), -sin(z), 0};
  matrixZ[1] = new float[]{sin(z), cos(z), 0};
  matrixZ[2] = new float[]{0, 0, 1};

  PVector out = new PVector();
  toMatrix(matrixX).mult(toRot, out);
  toMatrix(matrixY).mult(out, out);
  toMatrix(matrixZ).mult(out, out);

  return out;
}
class Object3D {
  final static int QUEUE_SIZE = 10;
  final static float THRESHOLD_VEL_STACK = 2.5f;
  final static float MASS_VOLUMIC_AIR = 1.225f;
  final static float GRAVITY = 9.81f;
  final static float ROT_VEL_DECELERATION = PI/500;
  final static float SLOW_ROT = 0.3f;
  final static float ROT_RESISTANCE = 0.4f;
  final static float THRESHOLD_ROT_VEL_MIN = PI/1000;
  final static float ARCHIMEDE_FACTOR = 2;
  Queue<Float> mLastVelocities;
  float mSumVelocities = 0;
  int mStackSize = 0;
  PVector mPosition;
  PVector mOldPosition;
  boolean mFloating;
  float mMass;
  float mVolumicMass;
  float mBounce;
  PVector mVelocity;
  PVector mAccel;
  PVector mRotVelocity;
  PVector mRot;
  PVector mOldRot;
  PShape mShape = null;
  SphereCollider mCollider;
  float mLengthTorque = -1;
  float mCenterToTop = 0;

  Object3D(PVector position, boolean floating, float mass, float volumicMass, float bounce, PVector velocity, PVector accel, PVector rot) {
    mPosition = position;
    mOldPosition = position;
    mFloating = floating;
    mMass = mass;
    mBounce = bounce;
    mVelocity = velocity;
    mAccel = accel;
    mVolumicMass = volumicMass;
    if (!floating) {
      mAccel.y -= ARCHIMEDE_FACTOR * GRAVITY * (volumicMass) * (4/3 * PI * 1.5f * 1.5f * 1.5f);
    }
    mRot = rot;
    mOldRot = rot;
    mRotVelocity = new PVector(0, 0, 0);
    mLastVelocities = new LinkedList();
  }

  //constructor with torque
  Object3D(PVector position, boolean floating, float mass, float volumicMass, float bounce, PVector velocity, PVector accel, PVector rot, float lengthTorque, float topTorqueRepartition) {
    this(position, floating, mass, volumicMass, bounce, velocity, accel, rot);
    mLengthTorque = lengthTorque;
    mCenterToTop = (1-topTorqueRepartition)*mLengthTorque;
  }

  public void addCollider(SphereCollider s) {
    mCollider = s;
  }

  public void setShape(PShape shape) {
    mShape = shape;
  }

  public PShape getShape() {
    return mShape;
  }

  /*SphereCollider getMovingSphereCollider()
   {
   if (mMovingCollider == null) { 
   PVector diff = (mPosition.sub(mOldPosition)).div(2);
   float radius = diff.mag();
   mMovingCollider = new SphereCollider(diff.add(mOldPosition), radius + mCollider.getRadius());
   }
   return mMovingCollider;
   }*/

  public SphereCollider getSphereCollider()
  {
    return mCollider;
  }

  /**
   * Update the position according to current object Acceleration and Velocity
   * dt in [second]
   **/
  public void Update(float dt)
  {
    //mMovingCollider = null;
    if (!mFloating) {
      float magn = mVelocity.mag();
      mLastVelocities.add(magn);
      mSumVelocities += magn;
      boolean doVelocityStuff = true;
      if(mStackSize < QUEUE_SIZE){
        ++mStackSize;
      }else{
        mSumVelocities -= mLastVelocities.poll();
        //println(mSumVelocities);
        if(mSumVelocities < THRESHOLD_VEL_STACK)
          doVelocityStuff = false;
      }
      
      
      mOldPosition = mPosition.copy();
      if(doVelocityStuff){
        mPosition = PVector.add(mPosition, PVector.mult(mAccel, .5f * dt * dt).add(PVector.mult(mVelocity, dt)));
        mVelocity.add(PVector.mult(mAccel, dt));
      }
      
      magn *= dt;
      mOldRot = mRot;
      mRot = PVector.add(mRot, mRotVelocity);
      
      float rotX = sin(mRot.x) * magn * ROT_VEL_DECELERATION * (mRot.x < PI ? -1 : 1);
      float rotZ = sin(mRot.z) * magn * ROT_VEL_DECELERATION * (mRot.z < PI ? -1 : 1);
      mRotVelocity.add(new PVector(rotX, 0, rotZ));
      //rot resistance (air resistance/frottements)
      mRotVelocity = PVector.add(PVector.mult(mRotVelocity, 1 - dt), PVector.mult(mRotVelocity, dt * ROT_RESISTANCE));
    }
  }

  public PVector getRot()
  {
    return mRot;
  }
  
  public PVector getOldRot(){
    return mOldRot; 
  }
  
  public void setRot(PVector rot){
    mRot = rot;  
  }

  public PVector getPosition()
  {
    return mPosition;
  }

  public PVector getOldPosition()
  {
    return mOldPosition;
  }

  public void setPosition(PVector newPos) {
    mPosition = newPos;
  }

  public boolean isFloating() {
    return mFloating;
  }

  public float getMass() {
    return mMass;
  }

  public PVector getVelocity() {
    return mVelocity;
  }

  public float getBounce() {
    return mBounce;
  }

  public void setVelocity(PVector velocity) {
    mVelocity = velocity;
  }
  
  public void setVelocity(PVector velocity, PVector collisionCenterRelative) {   
    if(mLengthTorque == -1){
      setVelocity(velocity);
      return;
    }
    
    PVector centerOnAxis = projectPointOnLine(collisionCenterRelative, AXIS_OBJECT3D, ORIGIN_OBJECT3D);
    
    PVector velocityWithRot = rot(PVector.mult(mRot, -1), velocity);
    
    PVector velocityRelativeAxis = PVector.add(centerOnAxis, velocityWithRot);
    PVector velocityOnAxis = projectPointOnLine(velocityRelativeAxis, AXIS_OBJECT3D, ORIGIN_OBJECT3D).sub(centerOnAxis);
    PVector velocityPerpendicular = PVector.sub(velocity, velocityOnAxis);
    boolean collisionInTop = centerOnAxis.y <= 0;
    float ratioVerticalVel = 0.7f + 0.3f * (1 - (collisionInTop ? -centerOnAxis.y/mCenterToTop : centerOnAxis.y/(mLengthTorque - mCenterToTop)));
    mVelocity = rot(mRot, PVector.add(velocityOnAxis, PVector.mult(velocityPerpendicular, ratioVerticalVel)));
    PVector angularVel = new PVector(velocityPerpendicular.z, 0, velocityPerpendicular.x).normalize().mult((1 - ratioVerticalVel)/mLengthTorque * velocityPerpendicular.mag() * SLOW_ROT);
    
    log("angular vel "+angularVel+" axis vel "+mVelocity);
    if(angularVel.mag() > THRESHOLD_ROT_VEL_MIN) 
      mRotVelocity.add(angularVel);
  }
}


public class SphereCollider {
  private Object3D mParent;
  private PVector mPosition;
  private float mRadius;
  private Set<SphereCollider> mChildren;
  private Set<Triangle> mTriangles;


  public SphereCollider(PVector position, float radius, Object3D parent, Set<SphereCollider> children)
  {
    mPosition = position;
    mRadius = radius;
    mChildren = children;
    mParent = parent;
    mTriangles = null;
  }

  /**
   * Position is relative to parent position
   **/
  public SphereCollider(PVector position, float radius, Object3D parent) {
    this(position, radius, parent, null);
  }

  public SphereCollider(PVector position, float radius, Set<Triangle> children, Object3D parent)
  {
    mPosition = position;
    mRadius = radius;
    mChildren = null;
    mParent = parent;
    mTriangles = children;
  }

  public float getRadius()
  {
    return mRadius;
  }

  public PVector getPosition()
  {
    return mPosition;
  }

  //boolean oldPosition to say if relative to old or new position
  public PVector getAbsolutePosition(boolean oldPosition)
  {
    PVector rot = oldPosition ? mParent.getOldRot() : mParent.getRot();
    float x = rot.x;
    float y = rot.y;
    float z = rot.z;

    float[][] matrixX = new float[3][3];
    matrixX[0] = new float[]{1, 0, 0, 0};
    matrixX[1] = new float[]{0, cos(x), -sin(x), 0};
    matrixX[2] = new float[]{0, sin(x), cos(x), 0};


    float[][] matrixY = new float[3][3];
    matrixY[0] = new float[]{ cos(y), 0, sin(y)};
    matrixY[1] = new float[]{0, 1, 0};
    matrixY[2] = new float[]{-sin(y), 0, cos(y)};


    float[][] matrixZ = new float[3][3];
    matrixZ[0] = new float[]{cos(z), -sin(z), 0};
    matrixZ[1] = new float[]{sin(z), cos(z), 0};
    matrixZ[2] = new float[]{0, 0, 1};

    

    PVector out = new PVector();
    toMatrix(matrixX).mult(mPosition, out);
    toMatrix(matrixY).mult(out, out);
    toMatrix(matrixZ).mult(out, out);
    

    return out.add(oldPosition ? mParent.getOldPosition() : mParent.getPosition());
  }

  public boolean isColliding(SphereCollider that)
  {
    return that.getAbsolutePosition(false).sub(this.getAbsolutePosition(false)).mag() <= that.mRadius + this.mRadius;
  }

  public Set<SphereCollider> getChildren()
  {
    return mChildren;
  }

  public boolean isRoot()
  {
    return mChildren == null;
  }

  public Object3D getParent() {
    return mParent;
  }

  public Set<Triangle> getTriangles()
  {
    return mTriangles;
  } 
}
class Util {
  public Util() {
  }
  
  
}
public class Triangle {
  Object3D mParent;
  PVector mV1, mV2, mV3;
  
  //Relative positions of the vertexes
  Triangle(PVector v1, PVector v2, PVector v3, Object3D parent) {
    mV1 = v1;
    mV2 = v2;
    mV3 = v3;
    mParent = parent;
  }
  
  public PVector[] getAbsolutePosition(boolean oldPosition){
    PVector rot = oldPosition ? mParent.getOldRot() : mParent.getRot();
    float x = rot.x;
    float y = rot.y;
    float z = rot.z;

    float[][] matrixX = new float[3][3];
    matrixX[0] = new float[]{1, 0, 0, 0};
    matrixX[1] = new float[]{0, cos(x), -sin(x), 0};
    matrixX[2] = new float[]{0, sin(x), cos(x), 0};


    float[][] matrixY = new float[3][3];
    matrixY[0] = new float[]{ cos(y), 0, sin(y)};
    matrixY[1] = new float[]{0, 1, 0};
    matrixY[2] = new float[]{-sin(y), 0, cos(y)};


    float[][] matrixZ = new float[3][3];
    matrixZ[0] = new float[]{cos(z), -sin(z), 0};
    matrixZ[1] = new float[]{sin(z), cos(z), 0};
    matrixZ[2] = new float[]{0, 0, 1};

    PVector[] out = new PVector[3];
    out[0] = new PVector();
    out[1] = new PVector();
    out[2] = new PVector();
    
    PMatrix3D matrix = toMatrix(matrixX);
    matrix.preApply(toMatrix(matrixY));
    matrix.preApply(toMatrix(matrixZ));
    
    matrix.mult(mV1, out[0]);    
    matrix.mult(mV2, out[1]);
    matrix.mult(mV3, out[2]);
    
    for(int i = 0; i < 3; ++i){
      out[i].add(oldPosition ? mParent.getOldPosition() : mParent.getPosition());
    }

    return out;
  }
  
  public boolean isColliding(Triangle that){
    //TODO using minkowski
    return false;
  }
  
  public Object3D getParent() {
    return mParent;
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "GameState" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
