import java.util.HashSet;

public class SphereCollider {
  private Object3D mParent;
  private PVector mPosition;
  private float mRadius;
  private Set<SphereCollider> mChildren;
  //private HashSet<Vertice> mVertices;


  public SphereCollider(PVector position, float radius, Set<SphereCollider> children)
  {
    mPosition = position;
    mRadius = radius;
    mChildren = children;
    //mVertices = null;
  }

  /**
   * Position is relative to parent position
   **/
  public SphereCollider(PVector position, float radius) {
    this(position, radius, null);
  }

  /*public SphereCollider(Vector3 position, float radius, HashSet<Vertice> children)
   {
   mPosition = position;
   mRadius = radius;
   mChildren = null;
   mVertices = children;
   }*/

  public float getRadius()
  {
    return mRadius;
  }

  public PVector getPosition()
  {
    return mPosition;
  }

  public PVector getAbsolutePosition()
  {
    PVector rot = mParent.getRot();
    float x = rot.x;
    float y = rot.y;
    float z = rot.z;

    float[][] matrixX = new float[3][3];
    matrixX[0] = new float[]{1, 0, 0, 0};
    matrixX[1] = new float[]{0, cos(x), -sin(x), 0};
    matrixX[2] = new float[]{0, sin(x), cos(x), 0};


    float[][] matrixY = new float[3][3];
    matrixX[0] = new float[]{ cos(y), 0, sin(y)};
    matrixX[1] = new float[]{0, 1, 0};
    matrixX[2] = new float[]{-sin(y), 0, cos(y)};


    float[][] matrixZ = new float[3][3];
    matrixZ[0] = new float[]{cos(z), -sin(z), 0};
    matrixZ[1] = new float[]{sin(z), cos(z), 0};
    matrixZ[2] = new float[]{0, 0, 1};


    return null;
  }

  public boolean isColliding(SphereCollider that)
  {
    return that.mPosition.sub(this.mPosition).mag() <= that.mRadius + this.mRadius;
  }

  public Set<SphereCollider> getChildren()
  {
    return mChildren;
  }

  public boolean isRoot()
  {
    return mChildren == null;
  }

  /*public HashSet<Vertice> getVertices()
   {
   return mVertices;
   }*/
}