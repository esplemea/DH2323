class Object3D {
  final static float MASS_VOLUMIC_AIR = 1.225;
  final static float GRAVITY = 9.81f;
  PVector mPosition;
  PVector mOldPosition;
  boolean mFloating;
  float mMass;
  float mVolumicMass;
  float mBounce;
  PVector mVelocity;
  PVector mAccel;
  PVector mRot;
  PShape mShape = null;
  SphereCollider mCollider;
  //SphereCollider mMovingCollider;

  Object3D(PVector position, boolean floating, float mass, float volumicMass, float bounce, PVector velocity, PVector accel, PVector rot) {
    mPosition = position;
    mOldPosition = position;
    mFloating = floating;
    mMass = mass;
    mBounce = bounce;
    mVelocity = velocity;
    mAccel = accel;
    mVolumicMass = volumicMass;
    if(!floating){
      mAccel.y -= 9.8 * (volumicMass) * (4/3 * PI * 1.5 * 1.5 * 1.5);
    }
    mRot = rot;
  }

  void addCollider(SphereCollider s) {
    mCollider = s;
  }
  
  void setShape(PShape shape){
    mShape = shape;
  }
  
  PShape getShape(){
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

  SphereCollider getSphereCollider()
  {
    return mCollider;
  }

  /**
   * Update the position according to current object Acceleration and Velocity
   * dt in [second]
   **/
  void Update(float dt)
  {
    //mMovingCollider = null;
    if (!mFloating) {
      mOldPosition = mPosition.copy();
      mPosition = PVector.add(mPosition, PVector.mult(mAccel, .5 * dt * dt).add(PVector.mult(mVelocity, dt)));
      mVelocity.add(PVector.mult(mAccel, dt));
    }
  }

  PVector getRot()
  {
    return mRot;
  }

  PVector getPosition()
  {
    return mPosition;
  }
  
  PVector getOldPosition()
  {
    return mOldPosition;
  }
  
  void setPosition(PVector newPos){
    mPosition = newPos;
  }

  boolean isFloating() {
    return mFloating;
  }
  
  float getMass(){
    return mMass;
  }
  
  PVector getVelocity(){
    return mVelocity; 
  }
  
  float getBounce(){
    return mBounce;  
  }
  
  void setVelocity(PVector velocity){
    mVelocity = velocity;  
  }
}