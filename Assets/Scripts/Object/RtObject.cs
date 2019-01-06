using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RtObject : MonoBehaviour {

    public enum MaterialRt
    {
        Invalid = 0,
        Lambertian = 1,
        Metal = 2,
        Dielectric = 3,
    }

    public MaterialRt Material;

    [Range(.01f, 1.5f)]
    public float ColorMultiplier = 1.0f;

    private Matrix4x4 m_lastTransform = Matrix4x4.identity;
    private float m_lastColorMultiplier;
    private Color m_lastColor;

    public Sphere GetSphere()
    {
        // Careful to handle colorspaces here.
        var albedo = GetComponent<MeshRenderer>().material.color.linear;
        var smoothness = GetComponent<MeshRenderer>().material.GetFloat("_Glossiness");
        albedo *= ColorMultiplier;

        var sphere = new Sphere();
        sphere.Albedo = new Vector3(albedo.r, albedo.g, albedo.b);
        sphere.Radius = transform.localScale.x / 2;
        sphere.Center = transform.position;
        sphere.Material.type = (int)Material;
        sphere.Material.scatterDistance = Material == MaterialRt.Metal ? 1 - smoothness : 0;
        print("smoothness " + smoothness);
        return sphere;
    }

    void OnEnable()
    {
        CSLoop.Instance.NotifySceneChanged();
        m_lastTransform = transform.localToWorldMatrix;
    }

    void OnDisable()
    {
        if (CSLoop.Instance != null)
        {
            CSLoop.Instance.NotifySceneChanged();
        }
    }

    void Update()
    {
        if (m_lastTransform != transform.localToWorldMatrix
            || m_lastColorMultiplier != ColorMultiplier
            || m_lastColor != GetComponent<MeshRenderer>().material.color)
        {
            m_lastColorMultiplier = ColorMultiplier;
            m_lastColor = GetComponent<MeshRenderer>().material.color;
            m_lastTransform = transform.localToWorldMatrix;
            CSLoop.Instance.NotifySceneChanged();
        }
    }

}

