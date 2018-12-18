using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RtObject : MonoBehaviour {

    public Color col;

    public Sphere toSphere()
    {
        Sphere sp = new Sphere();
        sp.center = transform.position;
        sp.radius = transform.lossyScale.x;
        sp.color = col;
        return sp;
    }
}
