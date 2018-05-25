public class Vertice {
  Object3D mParent;
  PVector mV1, mV2, mV3;
  
  //Relative positions of the vertexes
  Vertice(PVector v1, PVector v2, PVector v3, Object3D parent) {
    mV1 = v1;
    mV2 = v2;
    mV3 = v3;
    mParent = parent;
  }
  
  PVector[] getAbsolutePosition(boolean oldPosition){
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
  
  boolean isColliding(Vertice that){
    //TODO using minkowski
    return false;
  }
  
  Object3D getParent() {
    return mParent;
  }
}