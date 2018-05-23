import java.util.*; //<>// //<>//

// -----------------------------------------------------------------
float eyeX, eyeY, eyeZ;
float angUD = 0;
float angLR = 0;
int d = 200;
// -----------------------------------------------------------------
 
// -----------------------------------------------------------------
 
static final int THRESHOLD_COLLIDE_INSIDE_OBJECTS = 3;//may be usefull to do collisions multiple times in one fram, need to talk about it...
static final int THRESHOLD_COLLIDE_AGAIN_OBJECTS = 2;
static final int WALL_SIZE = 500;
;//may be usefull to do collisions multiple times in one fram, need to talk about it...
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
  eyeY = height/2;
  eyeZ = d;
  
  noStroke();
  balloon = loadShape("ballon-stripped-centered.obj");
  wall = createShape();
  wall.beginShape();
  wall.noStroke();
  wall.fill(200,200,255);

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
  roofWall.fill(210,210,210);
  roofWall.vertex(WALL_SIZE/2, 0, 0);
  roofWall.vertex(-WALL_SIZE/2, 0, 0);
  roofWall.vertex(0, -WALL_SIZE/2, WALL_SIZE/2);
  roofWall.endShape();

  mObjects = new ArrayList<Object3D>();
  mObjects.add(createDefaultSphere());
  /*Object3D o1 = new Object3D(new PVector(120, 120, 0), false, 10, 0.169f, 0.9f, new PVector(0, 0, -50), new PVector(0, 0, 0), new PVector(0, 0, 0));
  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 30, o1));
  mObjects.add(o1);*/

  /*Object3D o2 = new Object3D(new PVector(500, 0, 30), false, 10, 0.169f, 0.9f, new PVector(-50, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0));
  o2.addCollider(new SphereCollider(new PVector(0, 0, 0), 30, o2));
  mObjects.add(o2);*/

  PVector position = new PVector(250,0,0);
  PVector rotation = new PVector(0,0.5,0);
  createRoom(position, rotation);
}

// Update is called once per frame
void draw () {
  fill(255);
  background(0);
  lights();
  
  // CAMERA:
  if (eyeZ<0){
    camera(eyeX, eyeY, eyeZ, 
    width/2, height/2, 0, 
    0, -1, 0);
  }else{
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
  for (int i = 0; i < nbObjects; ++i)
  {
    for (int j = i + 1; j < nbObjects; ++j)
    {
      SphereCollider s1 = mObjects.get(i).getSphereCollider();
      SphereCollider s2 = mObjects.get(j).getSphereCollider();
      collides(s1, s2);
    }
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

        Object3D o2 = s2.getParent();
        oldPos = o2.getOldPosition();
        PVector pos2 = PVector.add(oldPos, PVector.sub(o2.getPosition(), oldPos).mult(sol));
        o2.setPosition(pos2);

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
          o1.setVelocity(PVector.mult(dir, velocity1));
        }
        if (!o2.isFloating()) {
          float velocity2 = (bounce*mass1*(speed1 - speed2) + mass1 * speed1 + mass2 * speed2)/(mass1 + mass2);
          o2.setVelocity(PVector.mult(dir, -velocity2));
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

Object3D createDefaultSphere() {
  //volumic mass 0.169 is for helium
  Object3D o1 = new Object3D(new PVector(250, 0, 0), false, 0, 0.169f, 0, new PVector(0, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0));
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
  mVertices.add(new Vertice(new PVector(WALL_SIZE/2, 0, 0), new PVector(-WALL_SIZE/2, 0, 0), new PVector(0, WALL_SIZE/2, WALL_SIZE/2), o1));

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
  println(System.currentTimeMillis() +" "+ message);
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
  for (Vertice v : vertices) {
    if (isColliding(s, v))
      return true;
  }
  return false;}

//the object containing the Vertice v is considered as floating, hence no mass, moving or backtracking!
boolean isColliding(SphereCollider s, Vertice v) {
  PVector[] vertices = v.getAbsolutePosition(false);
  PVector center = s.getAbsolutePosition(false);

  PVector v1v2 = PVector.sub(vertices[1], vertices[0]);
  PVector v1v3 = PVector.sub(vertices[2], vertices[0]);
  PVector v2v3 = PVector.sub(vertices[2], vertices[1]);
  PVector normal = v1v2.cross(v1v3).normalize();
  float c = -(normal.x*vertices[0].x+normal.y*vertices[0].y+normal.z*vertices[0].z);
  float radius = s.getRadius(); //<>//

  //log("center "+center+" normal "+normal+" c "+c);
  float distance = Math.abs(normal.dot(center) + c);
  //log("distance "+distance+" radius "+radius);
  if (distance > radius) {
    return false;
  }
  log("center "+center+" normal "+normal+" c "+c);
  log("distance "+distance+" radius "+radius);
  log("return true");

  boolean output = false;
  PVector oldCenter = s.getAbsolutePosition(true);
  PVector velocity = PVector.sub(center, oldCenter);
  float t0 = (radius - Math.abs((normal.dot(oldCenter) + c)))/normal.dot(velocity);
  PVector intersection = PVector.sub(oldCenter, normal).add(PVector.mult(velocity, t0));
  float squareRadius = radius * radius;
  PVector newCenter = PVector.add(oldCenter, PVector.mult(velocity, t0));

  if (checkPointInTriangUDle(intersection, vertices[0], vertices[1], vertices[2])) {
    log("intersect surface");
    output = true;
  } else {
    //check for each of the 3 vertices
    for (int i = 0; i < 3; ++i) {
      PVector cp = PVector.sub(vertices[i], center);
      if (cp.x*cp.x + cp.y*cp.y + cp.z*cp.z <= squareRadius) {
        log("intersect vertex "+i);
        output = true;
        break;
      }
    }

    //check for each of the 3 edges that the point is inside of them
    if (!output) {

      output = checkPointInSegment(vertices[0], vertices[1], center, v1v2, squareRadius);
      if (output)
        log("intersect edge1");
    }
    if (!output) {
      output = checkPointInSegment(vertices[0], vertices[2], center, v1v3, squareRadius);
      if (output)
        log("intersect edge2");
    }
    if (!output) {
      output = checkPointInSegment(vertices[1], vertices[2], center, v2v3, squareRadius);
      if (output)
        log("intersect edge3");
    }
  }

  if (output) {
    log("output true");
    //Backtrack the object with the sphere collider
    
    Object3D parent = s.getParent();
    parent.setPosition(newCenter);
    //todo direction
    /*PVector plan = normal.cross(velocity.cross(normal));
    log("plan "+plan+" normal "+normal+" velocity "+velocity);
    c = -(plan.x*newCenter.x+plan.y*newCenter.y+plan.z*newCenter.z);
    float distanceToPlan = Math.abs(plan.dot(oldCenter) + c);
    
    PVector newVelocity = (PVector.sub(PVector.add(oldCenter, PVector.mult(plan.normalize(), distanceToPlan * 2)), newCenter)).normalize();
    parent.setVelocity(newVelocity.mult(parent.getBounce() * v.getParent().getBounce() * parent.getVelocity().mag()));*/
    PVector newVelocity = PVector.sub(velocity, PVector.mult(normal, 2*normal.dot(velocity)));
    newVelocity = PVector.mult(newVelocity.normalize(), parent.getVelocity().mag() * parent.getBounce() * v.getParent().getBounce());
    parent.setVelocity(newVelocity);
    log("oldVelocity "+velocity+" new vel "+newVelocity);
  }
  println();
  return output;
}

boolean checkPointInTriangUDle(PVector point, PVector pa, PVector pb, PVector pc) {
  PVector e10 = PVector.sub(pb, pa);
  PVector e20 = PVector.sub(pc, pa);
  float a = e10.dot(e10);
  float b = e10.dot(e20);
  float c = e20.dot(e20);
  float ac_bb = (a*c) - (b*b);
  PVector vp = new PVector(point.x-pa.x, point.y-pa.y, point.z-pa.z);
  float d = vp.dot(e10);
  float e = vp.dot(e20);
  float x = (d*c)-(e*b);
  float y = (e*a)-(d*b);
  float z = x+y-ac_bb;
  return ((((long)z)& ~(((long)x)|((long)y)) ) & 0x80000000) != 0;//todo check this line...
}

//p is the center to project on line ab and check if between them
boolean checkPointInSegment(PVector a, PVector b, PVector p, PVector ab, float squareRadius) {
  PVector intersect = PVector.add(a, ab.mult(PVector.sub(a, p).dot(ab)/ab.dot(ab)));
  if (intersect.x*intersect.x + intersect.y*intersect.y + intersect.z*intersect.z > squareRadius)
    return false;
  if (ab.x != 0) {
    if (ab.x > 0 ? (intersect.x >= a.x && intersect.x <= b.x) : (intersect.x <= a.x && intersect.x >= b.x)) {
      return true;
    }
  } else if (ab.y != 0) {
    if (ab.y > 0 ? (intersect.y >= a.y && intersect.y <= b.y) : (intersect.y <= a.y && intersect.y >= b.y)) {
      return true;
    }
  } else {
    if (ab.z > 0 ? (intersect.z >= a.z && intersect.z <= b.z) : (intersect.z <= a.z && intersect.z >= b.z)) {
      return true;
    }
  }
  return false;
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
    // !CODED:
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
// --------------------------------------------------