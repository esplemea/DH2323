using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Object3D : MonoBehaviour {
    private Vector3 mPosition;
    private Vector3 mOldPosition;
    private bool mFloating;
    private float mMass;
    private float mBounce;
    private Vector3 mVelocity;
    private Vector3 mAccel;
    private Vector3 mRot;
    private SphereCollider mCollider;
    private SphereCollider mMovingCollider;

    public SphereCollider getMovingSphereCollider()
    {
        if (mMovingCollider == null) { 
            Vector3 diff = (mPosition - mOldPosition) / 2;
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

    public Vector3 getRot()
    {
        return mRot;
    }

    public Vector3 getPosition()
    {
        return mPosition;
    }
}
