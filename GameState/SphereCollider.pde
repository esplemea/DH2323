import java.util.HashSet;

public class SphereCollider {
  private Object3D mParent;
  private PVector mPosition;
  private float mRadius;
  private Set<SphereCollider> mChildren;
  private Set<Vertice> mVertices;


  public SphereCollider(PVector position, float radius, Object3D parent, Set<SphereCollider> children)
  {
    mPosition = position;
    mRadius = radius;
    mChildren = children;
    mParent = parent;
    mVertices = null;
  }

  /**
   * Position is relative to parent position
   **/
  public SphereCollider(PVector position, float radius, Object3D parent) {
    this(position, radius, parent, null);
  }

  public SphereCollider(PVector position, float radius, Set<Vertice> children, Object3D parent)
  {
    mPosition = position;
    mRadius = radius;
    mChildren = null;
    mParent = parent;
    mVertices = children;
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
  PVector getAbsolutePosition(boolean oldPosition)
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

  Object3D getParent() {
    return mParent;
  }

  Set<Vertice> getVertices()
  {
    return mVertices;
  }

  
}