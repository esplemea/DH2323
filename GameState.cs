using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameState : MonoBehaviour {
    private static readonly int THRESHOLD_COLLIDE_INSIDE_OBJECTS = 3;
    private static readonly int THRESHOLD_COLLIDE_AGAIN_OBJECTS = 2;

    private List<Object3D> mObjects;

    public void AddObject3D(Object3D toAdd)
    {
        mObjects.Add(toAdd);
    }

    public void RemoveObject3D(Object3D toRemove)
    {
        mObjects.Remove(toRemove);
    }

	// Use this for initialization
	void Start () {
        mObjects = new List<Object3D>();
    }
	
	// Update is called once per frame
	void Update () {
        float dt = Time.deltaTime;
        foreach (Object3D o in mObjects)
        {
            o.UpdateDt(dt);
        }

        int nbObjects = mObjects.Count;
        for(int i = 0; i < nbObjects; ++i)
        {
            for(int j = i + 1; j < nbObjects; ++j)
            {
                SphereCollider s1 = mObjects[i].getSphereCollider();
                SphereCollider s2 = mObjects[j].getSphereCollider();

            }
        }
    }

    private bool collides(SphereCollider s1, SphereCollider s2)
    {
        if(s1.isRoot() && s2.isRoot())
        {
            //TODO MOVE THE OBJECTS if isColliding()
            return s1.isColliding(s2);
        } else if (s1.isRoot())
        {
            return goThroughCollider(s2, s1);
        }
        else if(s2.isRoot())
        {
            return goThroughCollider(s1, s2);
        }
        if(s1.getChildren().Count > s2.getChildren().Count){
            return goThroughCollider(s2, s1);
        }
        return goThroughCollider(s1, s2);
    }

    private bool goThroughCollider(SphereCollider toGoThrough, SphereCollider s1)
    {
        foreach (SphereCollider s in toGoThrough.getChildren())
        {
            bool exit = collides(s1, s);
            if (exit)
                return true;
        }
        return false;
    }

    public List<GameObject> getChildren()
    {
        List<GameObject> gs = new List<GameObject>();
        Transform[] ts = gameObject.GetComponentsInChildren<Transform>();
        if (ts == null)
            return gs;
        foreach (Transform t in ts)
        {
            if (t != null && t.gameObject != null)
                gs.Add(t.gameObject);
        }
        return gs;
    }
}
