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
    //TODO archimede/gravity formula, not sure how to do it x)
    //mAccel.y += ???;
    mRot = rot;
  }

  void addCollider(SphereCollider s) {
    mCollider = s;
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
      mOldPosition = mPosition;
      mPosition.add(PVector.mult(mAccel, .5 * dt * dt).add(PVector.mult(mVelocity, dt)));
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

  boolean isFloating() {
    return mFloating;
  }
}