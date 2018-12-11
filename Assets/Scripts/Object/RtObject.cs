using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RtObject : MonoBehaviour {

    public Sphere toSphere()
    {
        Sphere sp = new Sphere();
        sp.center = transform.position;
        sp.radius = transform.lossyScale.x;
        return sp;
    }
}
