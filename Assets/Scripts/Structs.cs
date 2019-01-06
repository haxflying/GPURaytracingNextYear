using UnityEngine;
using System.Collections;

public struct Sphere
{
    public Vector3 Center;
    public float Radius;
    public Mat Material;
    public Vector3 Albedo;
}

public struct Mat
{
    public int type;
    public float scatterDistance;
}


public static class DataSize
{
    public static int Sphere
    {
        get
        {
            return 7 * sizeof(float) + Mat;
        }        
    }

    public static int Mat
    {
        get
        {
            return sizeof(float) + sizeof(int);
        }
    }

    public static int Ray
    {
        get
        {
            return 13 * sizeof(float) + sizeof(int) + Mat;
        }
    }
}