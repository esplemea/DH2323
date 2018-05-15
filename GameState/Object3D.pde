public class Object3D {
    private PVector mPosition;
    private PVector mOldPosition;
    private boolean mFloating;
    private float mMass;
    private float mBounce;
    private PVector mVelocity;
    private PVector mAccel;
    private PVector mRot;
    private SphereCollider mCollider;
    private SphereCollider mMovingCollider;

    public SphereCollider getMovingSphereCollider()
    {
        if (mMovingCollider == null) { 
            PVector diff = (mPosition - mOldPosition) / 2;
            float radius = diff.magnitude;
            mMovingCollider = new SphereCollider(diff + mOldPosition, radius + mCollider.getRadius());
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
        mPosition += .5f * mAccel * dt * dt + mVelocity * dt;
        mVelocity += mAccel * dt;
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
