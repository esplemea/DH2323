import java.util.*;

static final int THRESHOLD_COLLIDE_INSIDE_OBJECTS = 3;//may be usefull to do collisions multiple times in one fram, need to talk about it...
static final int THRESHOLD_COLLIDE_AGAIN_OBJECTS = 2;
;//may be usefull to do collisions multiple times in one fram, need to talk about it...
static long lastTime = 0;
int k = 0;

static List<Object3D> mObjects;
PShape balloon;

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
  noStroke();

  mObjects = new ArrayList<Object3D>();
  //mObjects.add(createDefaultSphere());
  Object3D o1 = new Object3D(new PVector(0, 0, -29.9), false, 10, 0.169f, 0.9f, new PVector(50, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0));
  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 30, o1));
  mObjects.add(o1);

  Object3D o2 = new Object3D(new PVector(500, 0, 30), false, 10, 0.169f, 0.9f, new PVector(-50, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0));
  o2.addCollider(new SphereCollider(new PVector(0, 0, 0), 30, o2));
  mObjects.add(o2);


  //balloon = loadShape("ballon-stripped-centered.obj");
}

// Update is called once per frame
void draw () {
  fill(255);
  background(0);
  lights();

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
    sphere(o.getSphereCollider().getRadius());
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
    if (s1.isColliding(s2)) {
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

      double cosAngle = Math.cos(PVector.angleBetween(v1, v2));
      double magV1 = v1.mag();
      double magV2 = v2.mag();
      double sqrtDelta = Math.sqrt(Math.pow(2*magV1*magV2*cosAngle, 2) - 4*Math.pow(magV1, 2)*(Math.pow(magV2, 2) - Math.pow(s1.getRadius() + s2.getRadius(), 2)));
      double b = 2*magV1*magV2*cosAngle;
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
        
        if (!o1.isFloating()){
          float velocity1 = (bounce*mass2*(speed2 - speed1) + mass1 * speed1 + mass2 * speed2)/(mass1 + mass2);
          log("v1 "+velocity1);
          o1.setVelocity(PVector.mult(dir, velocity1));
        }
        if (!o2.isFloating()){
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
  Object3D o1 = new Object3D(new PVector(0, 0, 0), false, 0, 0.169f, 0, new PVector(0, 0, 0), new PVector(0, 0, 0), new PVector(0, 0, 0));
  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 30, o1));
  return o1;
}

void log(String message) {
  println(System.currentTimeMillis() +" "+ message);
}

String PVectorToString(PVector p) { 
  return "PVector("+p.x+","+p.y+","+p.z+")";
}