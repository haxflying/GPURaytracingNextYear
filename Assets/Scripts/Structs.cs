using UnityEngine;
using System.Collections;

public struct Sphere
{
    public Vector3 center;
    public float radius;
}

public struct zRay
{
    public Vector3 origin;
    public Vector3 direction;

}

public static class DataSize
{
    public static int Sphere()
    {
        return 4 * sizeof(float);
    }

    public static int zRay()
    {
        return 6 * sizeof(float);
    }
}