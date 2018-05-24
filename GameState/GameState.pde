import java.util.*; //<>// //<>//

// -----------------------------------------------------------------
float eyeX, eyeY, eyeZ;
float angUD = 0;
float angLR = 0;
int d = 1000;
// -----------------------------------------------------------------

final static PVector AXIS_OBJECT3D = new PVector(0, -1, 0);
final static PVector ORIGIN_OBJECT3D = new PVector(0, 0, 0);
static final int THRESHOLD_COLLIDE_AGAIN_OBJECTS = 2;//re-check the same item in one frame after a collision
static final int WALL_SIZE = 500;
static final float EPSILON_COLLISION_TRIANGLE = 0.01f;
static final float OVER_BACKTRACKING_TRIANGLE = 10f;
static long lastTime = 0;
int k = 0;

static List<Object3D> mObjects;
PShape balloon;
PShape wall;
PShape roofWall;

void addObject3D(Object3D toAdd)
{
  mObjects.add(toAdd);
}

void removeObject3D(Object3D toRemove)
{
  mObjects.remove(toRemove);
}

void settings() {
  size(500, 500, P3D);
}

void setup() {
  background(0);

  eyeX = width/2;
  eyeY = (height/2)-d*(sin(radians(angUD)));
  eyeZ = d*cos(radians(angUD));

  noStroke();
  balloon = loadShape("ballon-stripped-centered.obj");
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

  mObjects.add(createDefaultBalloon(new PVector(120f, 130f, 0)));
  mObjects.add(createDefaultBalloon(new PVector(250f, 130f, 0)));
  mObjects.add(createDefaultBalloon(new PVector(400f, 130f, 0)));
  mObjects.add(createDefaultBalloon(new PVector(250, 400f, -150)));
  mObjects.add(createDefaultBalloon(new PVector(250, 550f, 20)));
  mObjects.add(createDefaultBalloon(new PVector(250, 700f, 20)));
  mObjects.add(createDefaultBalloon(new PVector(250, 850f, 20)));
  mObjects.add(createDefaultBalloon(new PVector(250, 1000f, 20)));
  //mObjects.add(createDefaultBalloon(new PVector(400f, 400f, 240)));
  /*Object3D o1 = new Object3D(new PVector(120f, 130f, 0), false, 10, 0.169f, 0.9f, new PVector(0, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0));
   o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 30, o1));
   o1.setShape(balloon);
   mObjects.add(o1);*/

  PVector position = new PVector(250, 0, 0);
  PVector rotation = new PVector(0, 0.5, 0);
  createRoom(position, rotation);
  println("setup");
}

// Update is called once per frame
void draw () {  
  fill(255);
  background(0);
  //directionalLight(255, 255, 255, 0.1, -0.6, -0.3);
  //ambientLight(102,102,102);
  lights();

  // CAMERA:
  if (eyeZ<0) {
    camera(eyeX, eyeY, eyeZ, 
      width/2, height/2, 0, 
      0, -1, 0);
  } else {
    camera(eyeX, eyeY, eyeZ, 
      width/2, height/2, 0, 
      0, 1, 0);
  }

  translate(0, 250, 0);

  long newTime = System.currentTimeMillis();
  float dt = ((float)(newTime - lastTime))/1000;
  lastTime = newTime;
  for (Object3D o : mObjects)
  {
    if (dt < 1)
      o.Update(dt);
  }

  int nbObjects = mObjects.size();
  int looping = 0;
  boolean collided = false;
  for (int i = 0; i < nbObjects; ++i)
  {
    for (int j = i + 1; j < nbObjects; ++j)
    {
      SphereCollider s1 = mObjects.get(i).getSphereCollider();
      SphereCollider s2 = mObjects.get(j).getSphereCollider();
      if(collides(s1, s2)){
        if(looping++ < THRESHOLD_COLLIDE_AGAIN_OBJECTS){
          --i;
          collided = true;
        }
        break;
      }
    }
    if(!collided)
      looping = 0;
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

  /*
  directionalLight(50, 100, 125, 0, 1, 0);
   //ambientLight(102, 102, 102);
   ambientLight(255, 255, 255);
   background(200, 200, 200);
   fill(74, 178, 118, 80);
   sphere(30);
   shape(balloon);*/
}

boolean collides(SphereCollider s1, SphereCollider s2)
{
  if (s1.isRoot() && s2.isRoot())
  {
    if (s1.getVertices() != null && s2.getVertices() != null)
      return false;
    else if (s1.getVertices() != null) {
      goThroughVerticesCollision(s2, s1.getVertices());
    } else if (s2.getVertices() != null) {
      goThroughVerticesCollision(s1, s2.getVertices());
    } else if (s1.isColliding(s2)) {
      PVector oldPos1 = s1.getAbsolutePosition(true);
      log("oldPos1 : "+PVectorToString(oldPos1));
      PVector newPos1 = s1.getAbsolutePosition(false);
      log("newPos1 : "+PVectorToString(newPos1));
      PVector oldPos2 = s2.getAbsolutePosition(true);
      log("oldPos2 : "+PVectorToString(oldPos2));
      PVector newPos2 = s2.getAbsolutePosition(false);
      log("newPos2 : "+PVectorToString(newPos2));
      PVector v1 = PVector.sub(newPos2, oldPos2).add(newPos1);//.sub(oldPos1);
      PVector v2 = PVector.sub(oldPos2, oldPos1);

      double cosangle = Math.cos(PVector.angleBetween(v1, v2));
      double magV1 = v1.mag();
      double magV2 = v2.mag();
      double sqrtDelta = Math.sqrt(Math.pow(2*magV1*magV2*cosangle, 2) - 4*Math.pow(magV1, 2)*(Math.pow(magV2, 2) - Math.pow(s1.getRadius() + s2.getRadius(), 2)));
      double b = 2*magV1*magV2*cosangle;
      double a = 2*magV1*magV1;

      float sol1 = (float)((-b + sqrtDelta)/a);
      float sol2 = (float)((b + sqrtDelta)/a);
      float sol = -1;
      if (sol1 >= 0 && sol1 <= 1 && sol2 >= 0 && sol2 <= 1)
        sol = min(sol1, sol2);
      else if (sol1 >= 0 && sol1 <= 1)
        sol = sol1;
      else if (sol2 >= 0 && sol2 <= 1)
        sol = sol2;

      if (sol != -1) {
        //EPSILON to avoid bugs...
        /*sol -= 0.01f;
         sol *= 0.95f;
         if (sol < 0)
         sol = 0;*/

        //Move the objects backward
        log("moving objects "+sol);
        Object3D o1 = s1.getParent();
        PVector oldPos = o1.getOldPosition();
        PVector pos1 = PVector.add(oldPos, PVector.sub(o1.getPosition(), oldPos).mult(sol));
        o1.setPosition(pos1);
        o1.setRot(PVector.add(o1.getOldRot(), PVector.sub(o1.getRot(), o1.getOldRot()).mult(sol)));

        Object3D o2 = s2.getParent();
        oldPos = o2.getOldPosition();
        PVector pos2 = PVector.add(oldPos, PVector.sub(o2.getPosition(), oldPos).mult(sol));
        o2.setPosition(pos2);
        o2.setRot(PVector.add(o2.getOldRot(), PVector.sub(o2.getRot(), o2.getOldRot()).mult(sol)));
        
        println("distance min "+(s1.getRadius() + s2.getRadius())+" real distance "+PVector.sub(pos2, pos1).mag());

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
          float velocity2 = (bounce*mass1*(speed1 - speed2) + mass1 * speed1 + mass2 * speed2)/(mass1 + mass2);
          o2.setVelocity(PVector.mult(dir, -velocity2), s2.getPosition());
        }
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

boolean goThroughCollider(SphereCollider toGoThrough, SphereCollider s1)
{
  for (SphereCollider s : toGoThrough.getChildren())
  {
    boolean exit = collides(s1, s);
    if (exit)
      return true;
  }
  return false;
}

void translate(PVector p) {
  translate(p.x, p.y, p.z);
}

Object3D createDefaultBalloon(PVector position) {
  //volumic mass 0.169 is for heliumy
  Object3D o1 = new Object3D(position, false, 10, 0.169f, 0.5f, new PVector(0, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0), 100, 0.7);
  o1.setShape(balloon);

  Set<SphereCollider> mChildren = new HashSet();
  mChildren.add(new SphereCollider(new PVector(0, -15, 0), 50, o1));
  mChildren.add(new SphereCollider(new PVector(0, 39, 0), 25, o1));
  mChildren.add(new SphereCollider(new PVector(6, 26, 0), 30, o1));
  mChildren.add(new SphereCollider(new PVector(-3, 26, -5.2), 30, o1));
  mChildren.add(new SphereCollider(new PVector(-3, 26, 5.2), 30, o1));
  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 65, o1, mChildren));

  return o1;
}

//Create default square shaped wall of size 500x500
Object3D createWall(PVector position, PVector rot) {
  Object3D o1 = new Object3D(position, false, 0, 0, 1, new PVector(0, 0, 0), new PVector(0, 0, 0), rot);
  float radius = (float)(Math.pow(WALL_SIZE*WALL_SIZE/2, 0.5));

  Set<Vertice> mVertices = new HashSet();
  mVertices.add(new Vertice(new PVector(WALL_SIZE/2, WALL_SIZE/2, 0), new PVector(WALL_SIZE/2, -WALL_SIZE/2, 0), new PVector(-WALL_SIZE/2, -WALL_SIZE/2, 0), o1));
  mVertices.add(new Vertice(new PVector(WALL_SIZE/2, WALL_SIZE/2, 0), new PVector(-WALL_SIZE/2, WALL_SIZE/2, 0), new PVector(-WALL_SIZE/2, -WALL_SIZE/2, 0), o1));

  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), radius, mVertices, o1));
  o1.setShape(wall);
  return o1; //<>//
}

//Create default square shaped wall of size 500x500
Object3D createRoofWall(PVector position, PVector rot) {
  Object3D o1 = new Object3D(position, false, 0, 0, 1, new PVector(0, 0, 0), new PVector(0, 0, 0), rot);
  float radius = (float)(Math.pow(WALL_SIZE*WALL_SIZE/2, 0.5));

  Set<Vertice> mVertices = new HashSet();
  mVertices.add(new Vertice(new PVector(WALL_SIZE/2, 0, 0), new PVector(-WALL_SIZE/2, 0, 0), new PVector(0, -WALL_SIZE/2, WALL_SIZE/2), o1));

  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), radius, mVertices, o1));
  o1.setShape(roofWall);
  return o1;
}

//Create default square shaped wall of size 500x500
void createRoom(PVector position, PVector rot) {
  mObjects.add(createWall(position.copy().add(new PVector(0, 0, -WALL_SIZE/2)), new PVector(0, 0, 0)));
  mObjects.add(createWall(position.copy().add(new PVector(0, 0, WALL_SIZE/2)), new PVector(0, 0, 0)));
  mObjects.add(createWall(position.copy().add(new PVector(-WALL_SIZE/2, 0, 0)), new PVector(0, PI/2, 0)));
  mObjects.add(createWall(position.copy().add(new PVector(WALL_SIZE/2, 0, 0)), new PVector(0, PI/2, 0)));

  mObjects.add(createRoofWall(position.copy().add(new PVector(0, -WALL_SIZE/2, -WALL_SIZE/2)), new PVector(0, 0, 0)));
  mObjects.add(createRoofWall(position.copy().add(new PVector(0, -WALL_SIZE/2, WALL_SIZE/2)), new PVector(0, PI, 0)));
  mObjects.add(createRoofWall(position.copy().add(new PVector(-WALL_SIZE/2, -WALL_SIZE/2, 0)), new PVector(0, PI/2, 0)));
  mObjects.add(createRoofWall(position.copy().add(new PVector(WALL_SIZE/2, -WALL_SIZE/2, 0)), new PVector(0, -PI/2, 0)));
}

void log(String message) {
  //println(System.currentTimeMillis() +" "+ message);
}

String PVectorToString(PVector p) { 
  return "PVector("+p.x+","+p.y+","+p.z+")";
}

//matrix is 3x3
PMatrix3D toMatrix(float[][] matrix) {
  return new PMatrix3D(matrix[0][0], matrix[0][1], matrix[0][2], 0, 
    matrix[1][0], matrix[1][1], matrix[1][2], 0, 
    matrix[2][0], matrix[2][1], matrix[2][2], 0, 
    0, 0, 0, 1);
}

boolean goThroughVerticesCollision(SphereCollider s, Set<Vertice> vertices) {
  for (Vertice v : vertices) { //<>//
    if (isCollidingSurface(s, v))
      return true;
  }
  for (Vertice v : vertices) {
    if (isCollidingEdges(s, v))
      return true;
  }
  return false;
}

void setNewCenter(Object3D parent, PVector absoluteCenterCollider, PVector newCenter){
  parent.setPosition(PVector.add(newCenter, PVector.sub(parent.getPosition(),  absoluteCenterCollider)));
}

//the object containing the Vertice v is considered as floating, hence no mass, moving or backtracking!
boolean isCollidingSurface(SphereCollider s, Vertice v) {
  PVector[] vertices = v.getAbsolutePosition(false);
  PVector center = s.getAbsolutePosition(false);

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

  PVector oldCenter = s.getAbsolutePosition(true);
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
    
    if(t0 >= 0 && t0 <= 1)
      parent.setRot(PVector.add(parent.getOldRot(), PVector.sub(parent.getRot(), parent.getOldRot()).mult(t0)));

    return true;
  }

  return false;
}

boolean isCollidingEdges(SphereCollider s, Vertice v) {
  PVector[] vertices = v.getAbsolutePosition(false);
  PVector center = s.getAbsolutePosition(false);
  PVector v1v2 = PVector.sub(vertices[1], vertices[0]);
  PVector v1v3 = PVector.sub(vertices[2], vertices[0]);
  PVector v2v3 = PVector.sub(vertices[2], vertices[1]);
  float radius = s.getRadius();


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
  } //<>//
  return false;
}

boolean checkPointInTriangle(PVector p, PVector a, PVector b, PVector c, PVector normal) {
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
boolean checkPointInSegmentAndReplace(PVector a, PVector b, PVector p, PVector ab, float radius, SphereCollider s, Vertice v) {
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

String arrayToString(float[] array) {
  String out ="[";
  for (int i = 0; i< array.length; ++i)
    out+=array[i]+",";
  return out + "]";
}

void keyPressed() {
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
  eyeY = (height/2)-d*(sin(radians(angUD)));
  eyeZ = d*cos(radians(angUD));
  //eyeX = (width/2)-d*(sin(radians(angLR)));
  println("angUDle "+angUD+": "+eyeX+" / "+eyeY+" / "+eyeZ);
}

//project a point on a line
PVector projectPointOnLine(PVector point, PVector line, PVector pointLine){ 
  float t = (line.x*(point.x - pointLine.x) + line.y*(point.y - pointLine.y) + line.z*(point.z - pointLine.z))/(line.x * line.x + line.y * line.y + line.z * line.z);
  return PVector.add(pointLine, PVector.mult(line, t));
}

PVector rot(PVector rot, PVector toRot){
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