using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class MainLoop : MonoBehaviour {

    public Shader initRaytracingShader;
    [Range(1f, 4f)]
    public float rtRenderScale = 1f;
    [Range(1, 5)]
    public float maxBounce = 2;
    private CommandBuffer cb_rt;
    private Camera cam;
    private ComputeBuffer objs_sphere;
    private Material initRaytracingMat;
    private int lastHitPos, lastHitNormal, lastHitColor;
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
            bufferData.Add(obj.GetSphere());
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
        cb_rt.SetGlobalInt("obj_spheres_length", objs_sphere.count);

        lastHitPos = Shader.PropertyToID("HitPos");
        lastHitNormal = Shader.PropertyToID("HitNormal");
        lastHitColor = Shader.PropertyToID("HitColor");

        RenderTargetIdentifier pos = new RenderTargetIdentifier(lastHitPos);
        RenderTargetIdentifier normal = new RenderTargetIdentifier(lastHitNormal);
        RenderTargetIdentifier color = new RenderTargetIdentifier(lastHitColor);

        cb_rt.GetTemporaryRT(lastHitPos, desc);
        cb_rt.GetTemporaryRT(lastHitNormal, desc);
        cb_rt.GetTemporaryRT(lastHitColor, desc);

        cb_rt.EnableShaderKeyword("_INIT");
        cb_rt.SetRenderTarget(new RenderTargetIdentifier[] { pos, normal, color}, pos);
        cb_rt.Blit(null, BuiltinRenderTextureType.CurrentActive, initRaytracingMat);

        cb_rt.DisableShaderKeyword("_INIT");
        int bufferPos = Shader.PropertyToID("HitPos_");
        int bufferNormal = Shader.PropertyToID("HitNormal_");
        int bufferColor = Shader.PropertyToID("HitColor_");
        RenderTargetIdentifier posBuffer = new RenderTargetIdentifier(bufferPos);
        RenderTargetIdentifier normalBuffer = new RenderTargetIdentifier(bufferNormal);
        RenderTargetIdentifier colorBuffer = new RenderTargetIdentifier(bufferColor);

        cb_rt.GetTemporaryRT(bufferPos, desc);
        cb_rt.GetTemporaryRT(bufferNormal, desc);
        cb_rt.GetTemporaryRT(bufferColor, desc);


        for (int i = 0; i < maxBounce; i++)
        {
            if (i % 2 == 0)
            {              
                cb_rt.SetRenderTarget(new RenderTargetIdentifier[] { posBuffer, normalBuffer, colorBuffer }, posBuffer);
                cb_rt.SetGlobalTexture("_TexLastHitPos", lastHitPos);
                cb_rt.SetGlobalTexture("_TexLastHitNormal", lastHitNormal);
                cb_rt.SetGlobalTexture("_TexLastHitColor", lastHitColor);
                cb_rt.Blit(null, BuiltinRenderTextureType.CurrentActive, initRaytracingMat);
            }
            else
            {
                //cb_rt.Blit(color, colorBuffer);
                cb_rt.SetRenderTarget(new RenderTargetIdentifier[] { pos, normal, color }, pos);
                cb_rt.SetGlobalTexture("_TexLastHitPos", posBuffer);
                cb_rt.SetGlobalTexture("_TexLastHitNormal", normalBuffer);
                cb_rt.SetGlobalTexture("_TexLastHitColor", colorBuffer);
                cb_rt.Blit(null, BuiltinRenderTextureType.CurrentActive, initRaytracingMat);
            }
        }

        currentRtResult = RenderTexture.GetTemporary(desc);
        if(maxBounce % 2 == 1)
        {
            cb_rt.Blit(colorBuffer, currentRtResult);
        }
        else
        {
            cb_rt.Blit(color, currentRtResult);
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst);
    }
}
