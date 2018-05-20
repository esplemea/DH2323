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
  mObjects.add(createDefaultSphere());
  
  balloon = loadShape("ballon-stripped-centered.obj");
}

// Update is called once per frame
void draw () {
  fill(255);
  background(0);
  lights();

  translate(250, 0, 0);

  long newTime = System.currentTimeMillis();
  float dt = ((float)(newTime - lastTime))/1000;
  lastTime = newTime;
  for (Object3D o : mObjects)
  {
    if (dt < 1)
      o.Update(dt);
    pushMatrix();
    translate(o.getPosition());
    sphere(o.getSphereCollider().getRadius());
    popMatrix();
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

  noStroke();
  directionalLight(50, 100, 125, 0, 1, 0);
  //ambientLight(102, 102, 102);
  ambientLight(255, 255, 255);
  background(200,200,200);
  fill(74, 178, 118, 80);
  sphere(30);
  shape(balloon);
}

boolean collides(SphereCollider s1, SphereCollider s2)
{
  if (s1.isRoot() && s2.isRoot())
  {
    //TODO MOVE THE OBJECTS if isColliding()
    return s1.isColliding(s2);
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
  Set<SphereCollider> mChildren = new HashSet<>();
  mChildren.add(new SphereCollider(new PVector(0,-15,0),50));
  mChildren.add(new SphereCollider(new PVector(0,39,0),25));
  mChildren.add(new SphereCollider(new PVector(6,26,0),30));
  mChildren.add(new SphereCollider(new PVector(-3,26,-5.2),30));
  mChildren.add(new SphereCollider(new PVector(-3,26,5.2),30));
  o1.addCollider(new SphereCollider(new PVector(0, 0, 0), 65, mChildren));
  return o1;
}