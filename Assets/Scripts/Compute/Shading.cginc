#define kMaterialInvalid 0
#define kMaterialLambertian 1

bool Refract(float3 v, float3 n, float niOverNt, out float3 refracted)
{
    float3 uv = normalize(v);
    float dt = dot(uv, n);
    float discriminant = 1.0 - niOverNt * niOverNt * (1 - dt * dt);
    if (discriminant > 0)
    {
        refracted = niOverNt * (v - n * dt) - n * sqrt(discriminant);
        return true;
    }
    return false;
}

float Schlick(float cosine, float refIdx)
{
    float r0 = (1 - refIdx) / (1 + refIdx);
    r0 = r0 * r0;
    return r0 + (1 - r0) * pow((1 - cosine), 5);
}
vec3 EnvColor(Ray r, vec2 uv)
{
    vec3 unitDirection = normalize(r.direction);
    float t = 0.5 * (unitDirection.y + 1.0);
    return 1.0 * ((1.0 - t) * vec3(1.0, 1.0, 1.0) + t * vec3(0.5, 0.7, 1.0));
}

bool ScatterLambertian(Ray rIn, HitRecord rec, inout vec3 attenuation, inout Ray scattered)
{


    vec3 target = rec.p + rec.normal + RandomInUnitSphere(rec.uv);
  
    scattered.origin = rec.p + .001 * rec.normal;
    scattered.direction = target - rec.p;
    scattered.color = rIn.color;
    scattered.bounces = rIn.bounces;
    scattered.material = kMaterialLambertian;
  
    attenuation = rec.albedo;
    return true;
}