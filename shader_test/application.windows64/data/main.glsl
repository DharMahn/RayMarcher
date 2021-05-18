#ifdef GL_ES
precision lowp float;
#endif

#define maxDst 100.0;
#define minDst 0.0001;
#define maxObj=12;

struct Shape {
    vec3 position;
    vec3 size;
    vec3 colour;
    int shapeType;
};

struct Ray {
    vec3 origin;
    vec3 direction;
};

struct Camera{
    vec3 Forward;
    vec3 Pos;
    vec3 Right;
    vec3 Up;
};

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform vec3 camPos;
uniform vec3 lookAt;

const vec3 ambientLight=vec3(0.0,0.0,0.0);
const vec3 k_a=vec3(0.0,0.0,0.0);
const vec3 k_d=vec3(0.2,0.2,0.2);
const vec3 k_s=vec3(1.0,1.0,1.0);
const float shininess=1.0;

Camera c;


Camera createCamera(vec3 pos, vec3 lookAt){
    Camera c;
    c.Forward = normalize(lookAt-pos);
    c.Pos = pos;
    vec3 Down = vec3(0,-1,0);
    c.Right = normalize(cross(c.Forward,Down))*1.5;
    c.Up = normalize(cross(c.Forward,c.Right))*1.5;
    return c;
}

uniform vec3 pos[12];
uniform vec3 size[12];
uniform vec3 colour[12];
uniform int shapeType[12];


float RecenterX(){
    return (gl_FragCoord.x - (u_resolution.x / 2.0)) / (0.9 * u_resolution.x);
}

float RecenterY(){
    return -(gl_FragCoord.y - (u_resolution.y / 2.0)) / (1.6 * u_resolution.y);
}

vec3 GetPoint(Camera c){
    return normalize(c.Forward+((RecenterX()*c.Right)+(RecenterY()*c.Up)));
}

float PlaneDistance(vec3 eye, vec3 centre, vec3 n, float h )
{
    //vec3 q=abs(centre-eye);
    // n must be normalized
    return dot(abs(centre-eye),n) + h;
}

float SphereDistance(vec3 eye, vec3 centre, float radius) {
    return distance(eye, centre) - radius;
}

float CubeDistance(vec3 eye, vec3 centre, vec3 size )
{
  vec3 q = abs(centre - eye) - size;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float TorusDistance(vec3 eye, vec3 centre, vec2 h)
{   
    vec2 q = vec2(length((eye-centre).xz)-h.x,eye.y-centre.y);
    return length(q)-h.y;
}

float PrismDistance(vec3 eye, vec3 centre, vec2 h) {
    vec3 q = abs(eye-centre);
    return max(q.z-h.y,max(q.x*0.866025+eye.y*0.5,-eye.y)-h.x*0.5);
}

//broken
float CylinderDistance(vec3 eye, vec3 centre, vec2 h) {
    vec2 d = abs(vec2(length(eye.xz), eye.y)) - h;
    return length(max(d,0.0)) + max(min(d.x,0.0),min(d. y,0.0));
}


float GetShapeDistance(vec3 p, Shape s){
    float dstToScene=maxDst;
    float dst;
    if (s.shapeType == 0) {
        dst = SphereDistance(p,s.position,s.size.x);
    }
    else if(s.shapeType == 1) {
        dst = CubeDistance(p,s.position,s.size);
    }
    else if(s.shapeType == 2){
        dst = TorusDistance(p,s.position,s.size.xy);
    }
    else if(s.shapeType == 3){
        dst = PrismDistance(p,s.position,s.size.xy);
    }
    else if(s.shapeType == 69){
        dst = PlaneDistance(p,s.position,normalize(s.size),1.0);
    }
    return min(dstToScene,dst);
}

float signedDstToScene(vec3 p, inout vec3 col){
    float dstToScene = maxDst;
    Shape s;
    float dst;
    for(int i = 0; i < 12; i++){
        //s = Shape(vec3(0,0,1),vec3(1,1,1),vec3(1,0.7,1),1);
        s = Shape(pos[i],size[i],colour[i],shapeType[i]);
        dst = GetShapeDistance(p,s);
        if(dst<dstToScene){
            col=s.colour;
            dstToScene=dst;
        }
    }
    return dstToScene;
}

float signedDstToScene(vec3 p){
    float minShapeDist = maxDst+1.0;
    Shape s;
    for(int i = 0; i < 12; i++){
        //s = Shape(vec3(0,0,1),vec3(1,1,1),vec3(1,0.7,1),1);
        s = Shape(pos[i],size[i],colour[i],shapeType[i]);
        minShapeDist = min(minShapeDist,GetShapeDistance(p,s));
    }
    return minShapeDist;
}

vec3 rayDirection(float fieldOfView, vec2 size, vec2 fragCoord) {
    vec2 xy = fragCoord - size / 2.0;
    float z = size.y / tan(radians(fieldOfView) / 2.0);
    return normalize(vec3(xy, -z));
}

vec3 Reflect(vec3 incidentVec, vec3 normal)
{
    return incidentVec - 2.0 * dot(incidentVec, normal) * normal;
}

vec3 estimateNormal(vec3 p)
        {
            return normalize(vec3(
                signedDstToScene(vec3(p.x + 0.0001, p.y, p.z)) - signedDstToScene(vec3(p.x - 0.0001, p.y, p.z)),
                signedDstToScene(vec3(p.x, p.y + 0.0001, p.z)) - signedDstToScene(vec3(p.x, p.y - 0.0001, p.z)),
                signedDstToScene(vec3(p.x, p.y, p.z + 0.0001)) - signedDstToScene(vec3(p.x, p.y, p.z - 0.0001))
            ));
        }



vec3 phongContribForLight(vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye, vec3 lightPos, vec3 lightIntensity)
        {
            vec3 n = estimateNormal(p);
            vec3 l = normalize(lightPos - p);
            vec3 v = normalize(eye - p);
            vec3 r = normalize(Reflect(-l, n));
            float dotLN = clamp(dot(l,n), 0.0, 1.0);
            float dotRV = dot(r, v);

            if (dotLN < 0.0)
            {
                return vec3(0.0,0.0,0.0);
            }
            if (dotRV < 0.0)
            {
                return lightIntensity * (k_d * dotLN);
            }
            return lightIntensity * (k_d * dotLN + k_s * (dotRV * alpha));
        }

vec3 phongIllumination(vec3 k_a, vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye)
        {
            vec3 color = ambientLight * k_a;
            vec3 light1Pos = c.Pos;
            light1Pos += vec3(0.0,-1.0,0.0);
            //vec3 light1Pos = vec3(4.0 * sin(u_time), -16.0, 8.0 * cos(u_time));
            vec3 light1Intensity = vec3(1.0, 1.0, 1.0);

            color += phongContribForLight(k_d, k_s, alpha, p, eye, light1Pos, light1Intensity) * 0.4545;

            /*Vector3 light2Pos = new Vector3(2.0f * (float)Math.Sin(rotation * 0.37f), 6.0f * (float)Math.Cos(rotation * 0.37f), 2.0f);
            Vector3 light2Intensity = new Vector3(0.4f, 0.4f, 0.4f);

            color += phongContribForLight(k_d, k_s, alpha, p, eye, light2Pos, light2Intensity);*/

            return color;

        }

void main() {

    c = createCamera(camPos,lookAt);
    //Ray r = Ray(c.Pos,rayDirection(75.0,u_resolution.xy,gl_FragCoord.xy));
    //mat4 viewToWorld = viewMatrix(c.pos, vec3(0.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0));
    Ray r = Ray(c.Pos,GetPoint(c));
    float rayDst = 0.0;
    float circleSize;
    float closestDst = maxDst;
    vec3 shapeCol;
    
    for(int i = 0; i < 200; i++){
        if(rayDst < 100.0)
        {
        
            circleSize = signedDstToScene(r.origin, shapeCol);
            if(circleSize < 0.001) 
            {
                gl_FragColor = vec4(phongIllumination(k_a,shapeCol,k_s,shininess,r.origin,c.Pos),1.0);
                
                return;
            }
            r.origin += r.direction * circleSize;
            rayDst += circleSize;
            closestDst=min(closestDst,circleSize);
        }
    }
    /*while(rayDst < 100.0)
    {
			
            circleSize = signedDstToScene(r.origin, shapeCol);
            if(circleSize < 0.001) 
            {
                //gl_FragColor = vec4(phongIllumination(k_a,shapeCol,k_s,shininess,r.origin,c.Pos),1.0);
                gl_FragColor = vec4(0.0,0.0,1.0,1.0);
                return;
            }
            r.origin += r.direction * circleSize;
            rayDst += circleSize;but u ca
            closestDst=min(closestDst,circleSize);
    }*/
    gl_FragColor=vec4(0.0,0.0,0.0,1.0);
    //gl_FragColor=vec4(1.0/closestDst,1.0/closestDst,1.0/closestDst,1.0);
}