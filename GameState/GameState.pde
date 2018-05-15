import java.util.*;

static final int THRESHOLD_COLLIDE_INSIDE_OBJECTS = 3;
static final int THRESHOLD_COLLIDE_AGAIN_OBJECTS = 2;
static long lastTime = 0;

static List<Object3D> mObjects;

void addObject3D(Object3D toAdd)
{
  mObjects.add(toAdd);
}

void removeObject3D(Object3D toRemove)
{
  mObjects.remove(toRemove);
}

// Use this for initialization
void Start () {
  mObjects = new ArrayList<Object3D>();
}

// Update is called once per frame
void draw () {
  long newTime = System.currentTimeMillis();
  float dt = ((float)(lastTime - newTime))/1000;
  lastTime = newTime;
  for (Object3D o : mObjects)
  {
    o.UpdateDt(dt);
  }

  int nbObjects = mObjects.size();
  for (int i = 0; i < nbObjects; ++i)
  {
    for (int j = i + 1; j < nbObjects; ++j)
    {
      SphereCollider s1 = mObjects.get(i).getSphereCollider();
      SphereCollider s2 = mObjects.get(j).getSphereCollider();
    }
  }
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
  if (s1.getChildren().Count > s2.getChildren().Count) {
    return goThroughCollider(s2, s1);
  }
  return goThroughCollider(s1, s2);
}

boolean goThroughCollider(SphereCollider toGoThrough, SphereCollider s1)
{
  foreach (SphereCollider s : toGoThrough.getChildren())
  {
    boolean exit = collides(s1, s);
    if (exit)
      return true;
  }
  return false;
}
