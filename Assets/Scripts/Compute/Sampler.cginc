float4 _Time;
float _Seed01;
float _R0, _R1, _R2;

StructuredBuffer<float3> _HemisphereSamples;

float GradNoise(float2 xy)
{
    return frac(52.9829189f * frac(0.06711056f * float(xy.x) + 0.00583715f * float(xy.y)));
}

float Noise(float2 uv)
{
    return GradNoise(floor(fmod(uv, 1024)) + _Seed01 * _Time.y);
}

float3 RandomInUnitSphere(float2 uv)
{
    float3 p;
    p = 2.0 * normalize(float3(Noise(uv * 2000 * (1 + _R0)) * 2 - .5,
                  Noise(uv * 2000 * (1 + _R1)) * 2 - .5,
                  Noise(uv * 2000 * (1 + _R2)) * 2 - .5)) - float3(1, 1, 1);

    p = 2.0 * normalize(float3(_R0, _R1, _R2)) - float3(1, 1, 1);
    p = _HemisphereSamples[(Noise(uv * 2000) * 392901) % 4096];
    return p;
}

float3 RandomInUnitDisk(float2 uv)
{
    return RandomInUnitSphere(uv);
}