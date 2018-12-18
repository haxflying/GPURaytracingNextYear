using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class MainLoop : MonoBehaviour {

    public Shader raytracingShader;
    [Range(0, 3)]
    public int indexTest;

    private CommandBuffer cb_rt;
    private Camera cam;
    private ComputeBuffer objs_sphere;
    private Material raytracingMat;

    private void Start()
    {
        cam = GetComponent<Camera>();
        cb_rt = new CommandBuffer();
        cb_rt.name = "RayTracing";
        raytracingMat = new Material(raytracingShader);


        cam.AddCommandBuffer(CameraEvent.AfterEverything, cb_rt);

        RtObject[] objs = FindObjectsOfType<RtObject>();
        List<Sphere> bufferData = new List<Sphere>();
        foreach(var obj in objs)
        {
            bufferData.Add(obj.toSphere());
        }
        objs_sphere = new ComputeBuffer(objs.Length, DataSize.Sphere());
        objs_sphere.SetData(bufferData.ToArray());        
    }

    private void OnPreRender()
    {
        if (cb_rt == null)
            return;

        cb_rt.Clear();
        cb_rt.SetGlobalBuffer("obj_spheres", objs_sphere);
        indexTest = Mathf.Min(objs_sphere.count, indexTest);
        cb_rt.SetGlobalInt("_index", indexTest);
        cb_rt.Blit(null, BuiltinRenderTextureType.CameraTarget, raytracingMat);
    }
}
