#define FLT_MAX 3.402823466e+38F
#define vec2 float2
#define vec3 float3
#define vec4 float4

struct Ray {
    float3 origin;
    float3 direction;
    float3 color;
    float4 accumColor;
    int bounces;
    int material;

    float3 PointAtParameter(float t)
    {
        return origin + t * direction;
    }
};

struct HitRecord
{
    float2 uv;
    float t;
    float3 p;
    float3 normal;
    float3 albedo;
    int material;
};

struct Sphere
{
    float3 center;
    float radius;
    int material;
    float3 albedo;

    bool Hit(Ray r, float tMin, float tMax, out HitRecord rec);
};

bool Sphere::Hit(Ray r, float tMin, float tMax, out HitRecord rec)
{
    rec.t = tMin;
    rec.p = 0;
    rec.normal = float3(0, 0, 1);
    rec.uv = 0;
    rec.albedo = albedo;
    rec.material = material;

    float3 oc = r.origin - center;
    float a = dot(r.direction, r.direction);
    float b = dot(oc, r.direction);
    float c = dot(oc, oc) - radius * radius;
    float discriminant = b * b - a * c;

    if(discriminant <= 0)
        return false;

    float temp = (-b - sqrt(discriminant)) / a;
    if(temp < tMax && temp > tMin)
    {
        rec.t = temp;
        rec.p = r.PointAtParameter(rec.t);
        rec.normal = normalize((rec.p - center) / radius);
        return true;
    }

    temp = (-b + sqrt(discriminant)) / a;
    if (temp < tMax && temp > tMin)
    {
        rec.t = temp;
        rec.p = r.PointAtParameter(rec.t);
        rec.normal = normalize((rec.p - center) / radius);
        return true;
    }

    return false;
}
