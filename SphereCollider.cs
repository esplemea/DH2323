using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereCollider {
    private Object3D mParent;
    private Vector3 mPosition;
    private float mRadius;
    private HashSet<SphereCollider> mChildren;
    //private HashSet<Vertice> mVertices;

    /**
     * Position is relative to parent position
     **/
    public SphereCollider(Vector3 position, float radius) : this(position, radius, null)
    {

    }

    public SphereCollider(Vector3 position, float radius, HashSet<SphereCollider> children)
    {
        mPosition = position;
        mRadius = radius;
        mChildren = children;
        //mVertices = null;
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

    public Vector3 getPosition()
    {
        return mPosition;
    }

    public Vector3 getAbsolutePosition()
    {
        Vector3 rot = mParent.getRot();
        float x = rot.x;
        float y = rot.y;
        float z = rot.z;

        Matrix4x4 matrixX = new Matrix4x4();
        matrixX.SetColumn(0, new Vector4(1, 0, 0, 0));
        matrixX.SetColumn(1, new Vector4(0, Mathf.Cos(x), -Mathf.Sin(x), 0));
        matrixX.SetColumn(2, new Vector4(0, Mathf.Sin(x), Mathf.Cos(x), 0));
        Vector3 pos = mParent.getPosition();
        matrix.SetColumn(3, new Vector4(pos.x, pos.y, pos.z, 1));
        return null;
    }

    public bool isColliding(SphereCollider that)
    {
        return (that.mPosition - this.mPosition).magnitude <= that.mRadius + this.mRadius;
    }

    public HashSet<SphereCollider> getChildren()
    {
        return mChildren;
    }

    public bool isRoot()
    {
        return mChildren == null;
    }

    /*public HashSet<Vertice> getVertices()
    {
        return mVertices;
    }*/
}
