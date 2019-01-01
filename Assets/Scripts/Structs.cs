using UnityEngine;
using System.Collections;

public struct Sphere
{
    public Vector3 Center;
    public float Radius;
    public int Material;
    public Vector3 Albedo;
}


public static class DataSize
{
    public static int Sphere()
    {
        return 8 * sizeof(float);
    }

}