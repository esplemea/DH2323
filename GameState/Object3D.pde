class Object3D {
  final static float MASS_VOLUMIC_AIR = 1.225;
  final static float GRAVITY = 9.81f;
  final static float ROT_VEL_DECELERATION = PI/500;
  final static float SLOW_ROT = 0.15f;
  final static float ROT_RESISTANCE = 0.4f;
  final static float THRESHOLD_ROT_VEL_MIN = PI/1000;
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
      mAccel.y -= GRAVITY * (volumicMass) * (4/3 * PI * 1.5 * 1.5 * 1.5);
    }
    mRot = rot;
    mOldRot = rot;
    mRotVelocity = new PVector(0, 0, 0);
  }

  //constructor with torque
  Object3D(PVector position, boolean floating, float mass, float volumicMass, float bounce, PVector velocity, PVector accel, PVector rot, float lengthTorque, float topTorqueRepartition) {
    this(position, floating, mass, volumicMass, bounce, velocity, accel, rot);
    mLengthTorque = lengthTorque;
    mCenterToTop = (1-topTorqueRepartition)*mLengthTorque;
  }

  void addCollider(SphereCollider s) {
    mCollider = s;
  }

  void setShape(PShape shape) {
    mShape = shape;
  }

  PShape getShape() {
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
      mOldRot = mRot;
      mRot = PVector.add(mRot, mRotVelocity);
      float magn = mVelocity.mag()*dt;
      float rotX = sin(mRot.x) * magn * ROT_VEL_DECELERATION * (mRot.x < PI ? -1 : 1);
      float rotZ = sin(mRot.z) * magn * ROT_VEL_DECELERATION * (mRot.z < PI ? -1 : 1);
      mRotVelocity.add(new PVector(rotX, 0, rotZ));
      //rot resistance (air resistance/frottements)
      mRotVelocity = PVector.add(PVector.mult(mRotVelocity, 1 - dt), PVector.mult(mRotVelocity, dt * ROT_RESISTANCE));
    }
  }

  PVector getRot()
  {
    return mRot;
  }
  
  PVector getOldRot(){
    return mOldRot; 
  }
  
  void setRot(PVector rot){
    mRot = rot;  
  }

  PVector getPosition()
  {
    return mPosition;
  }

  PVector getOldPosition()
  {
    return mOldPosition;
  }

  void setPosition(PVector newPos) {
    mPosition = newPos;
  }

  boolean isFloating() {
    return mFloating;
  }

  float getMass() {
    return mMass;
  }

  PVector getVelocity() {
    return mVelocity;
  }

  float getBounce() {
    return mBounce;
  }

  void setVelocity(PVector velocity) {
    mVelocity = velocity;
  }
  
  void setVelocity(PVector velocity, PVector collisionCenterRelative) {        
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