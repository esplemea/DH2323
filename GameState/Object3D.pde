public class Object3D {
    PVector mPosition;
    PVector mOldPosition;
    boolean mFloating;
    float mMass;
    float mBounce;
    PVector mVelocity;
    PVector mAccel;
    PVector mRot;
    SphereCollider mCollider;
    SphereCollider mMovingCollider;

    public SphereCollider getMovingSphereCollider()
    {
        if (mMovingCollider == null) { 
            PVector diff = (mPosition.sub(mOldPosition)).div(2);
            float radius = diff.mag();
            mMovingCollider = new SphereCollider(diff.add(mOldPosition), radius + mCollider.getRadius());
        }
        return mMovingCollider;
    }

    public SphereCollider getSphereCollider()
    {
        return mCollider;
    }

    void Start()
    {
        //GameState.AddObject(this);
    }

    void Update() { 

    }

    //Update the position according to current object Acceleration and Velocity
    public void UpdateDt(float dt)
    {
        mMovingCollider = null;
        mOldPosition = mPosition;
        mPosition = mPosition.add(mAccel.mult(.5f * dt * dt).add(mVelocity.mult(dt)));
        mVelocity = mVelocity.add(mAccel.mult(dt));
    }

    public PVector getRot()
    {
        return mRot;
    }

    public PVector getPosition()
    {
        return mPosition;
    }
}