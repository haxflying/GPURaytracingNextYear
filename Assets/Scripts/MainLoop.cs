using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class MainLoop : MonoBehaviour {

    public Shader initRaytracingShader;
    [Range(1f, 4f)]
    public float rtRenderScale = 1f;
    private CommandBuffer cb_rt;
    private Camera cam;
    private ComputeBuffer objs_sphere;
    private Material initRaytracingMat;
    private int lastHitPos, lastHitNormal;
    private RenderTexture currentRtResult;
    private RenderTextureDescriptor desc;

    private void Start()
    {
        cam = GetComponent<Camera>();
        cb_rt = new CommandBuffer();
        cb_rt.name = "RayTracing";
        initRaytracingMat = new Material(initRaytracingShader);


        cam.AddCommandBuffer(CameraEvent.BeforeImageEffects, cb_rt);

        RtObject[] objs = FindObjectsOfType<RtObject>();
        List<Sphere> bufferData = new List<Sphere>();
        foreach(var obj in objs)
        {
            bufferData.Add(obj.toSphere());
        }
        objs_sphere = new ComputeBuffer(objs.Length, DataSize.Sphere());
        objs_sphere.SetData(bufferData.ToArray());

        desc = new RenderTextureDescriptor(
            Mathf.FloorToInt(Screen.width * rtRenderScale),
            Mathf.FloorToInt(Screen.height * rtRenderScale),
            RenderTextureFormat.ARGB32, 24);
    }

    private void OnPreRender()
    {
        if (cb_rt == null)
            return;

        cb_rt.Clear();
        cb_rt.SetGlobalBuffer("obj_spheres", objs_sphere);

        lastHitPos = Shader.PropertyToID("_TexLastHitPos");
        lastHitNormal = Shader.PropertyToID("_TexLastHitNormal");

        RenderTargetIdentifier pos = new RenderTargetIdentifier(lastHitPos);
        RenderTargetIdentifier normal = new RenderTargetIdentifier(lastHitNormal);

        cb_rt.GetTemporaryRT(lastHitPos, desc);
        cb_rt.GetTemporaryRT(lastHitNormal, desc);

        cb_rt.SetRenderTarget(new RenderTargetIdentifier[] { pos, normal}, pos);
        cb_rt.Blit(null, BuiltinRenderTextureType.CurrentActive, initRaytracingMat);


    }

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        
    }
}
