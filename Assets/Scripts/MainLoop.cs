using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class MainLoop : MonoBehaviour {

    private Vector2Int targetResolution;
    public ComputeShader rayTraceCompute;
    private Camera cam;
    private CommandBuffer cb;
    private ComputeBuffer rtObjBuffer;
    private int _kernel;

    public void Start()
    {
        cam = GetComponent<Camera>();

        cb = new CommandBuffer();
        cb.name = "RayTracing";

        cam.AddCommandBufferAsync(CameraEvent.BeforeImageEffects, cb, ComputeQueueType.Default);
        _kernel = rayTraceCompute.FindKernel("CSMain");

        targetResolution = new Vector2Int(800, 400);
        RtObject[] objs = FindObjectsOfType<RtObject>();
        List<Sphere> list = new List<Sphere>();
        foreach(var obj in objs)
        {
            list.Add(obj.toSphere());
        }
        rayTraceCompute.SetBuffer(_kernel, "objs", rtObjBuffer);
    }

    private void OnPreRender()
    {
        if (cb == null)
            return;

        cb.Clear();
        cb.DispatchCompute(rayTraceCompute, _kernel, targetResolution.x / 2, targetResolution.y / 2, 1);
    }
}
