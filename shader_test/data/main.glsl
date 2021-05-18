#ifdef GL_ES
precision mediump float;
#endif
//#define FRACTALS
#define maxDst 500.0
#define minDst 0.001
#define maxObj 10
#define maxLights 2

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

struct Light{
	vec3 Pos;
	vec3 Intensity;
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

uniform vec3 pos[maxObj];
uniform vec3 size[maxObj];
uniform vec3 colour[maxObj];
uniform int shapeType[maxObj];
uniform vec3 lightspos[maxLights];
uniform vec3 lightsintensity[maxLights];

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

float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); }

float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h); }

float opSmoothIntersection( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) + k*h*(1.0-h); }
	
float opOnion( in float sdf, in float thickness ){
    return abs(sdf)-thickness; }

float RecenterX(){
    return (gl_FragCoord.x - (u_resolution.x / 2.0)) / ( u_resolution.x);
}

float RecenterY(){
    return (gl_FragCoord.y - (u_resolution.y / 2.0)) / ( u_resolution.y);
}

vec3 GetPoint(Camera c){
    return normalize(c.Forward+((RecenterX()*c.Right)+(RecenterY()*c.Up)));
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

float InfiniteSpheres(vec3 z){
    z.xyz=mod((z.xyz),20.0)-vec3(10.0);
    return length(z)-3.0;
}

float PlaneDistance(vec3 p, vec3 centre)
{
	return p.y-centre.y;
}

float Sierpinski2(vec3 z)
{
	float Scale=200.0; //20.0 is safe
	float Offset=2.0;
    float r;
    int n = 0;
    while (n < 20) {
       if(z.x+z.y<0.0) z.xy = -z.yx; // fold 1
       if(z.x+z.z<0.0) z.xz = -z.zx; // fold 2
       if(z.y+z.z<0.0) z.zy = -z.yz; // fold 3	
       z = z*Offset - Scale*(Offset-1.0);
       n++;
    }
    return (length(z) ) * pow(Offset, -float(n));
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
        dst = PlaneDistance(p,s.position);
    }
    return min(dstToScene,dst);
}

float signedDstToSceneSmooth(vec3 p, inout vec3 col){
    float dstToScene = maxDst;
    Shape s;
    float dst;
    for(int i = 0; i < maxObj; i++){
        s = Shape(pos[i],size[i],colour[i],shapeType[i]);
        //dst = GetShapeDistance(p,s);
		for(int j = 0; j < maxObj; j++){
			if(i == j)continue;
			Shape stemp = Shape(pos[j],size[j],colour[j],shapeType[j]);
			dst = opSmoothUnion(GetShapeDistance(p,s),GetShapeDistance(p,stemp),1.0);
			if(dst<dstToScene){
				col=s.colour;
				dstToScene=dst;
			}
		}
    }
    return dstToScene;
}
float signedDstToSceneSmooth(vec3 p){
    float dstToScene = maxDst;
    Shape s;
    float dst;
    for(int i = 0; i < maxObj; i++){
        s = Shape(pos[i],size[i],colour[i],shapeType[i]);
        //dst = GetShapeDistance(p,s);
		for(int j = 0; j < maxObj; j++){
			if(i == j)continue;
			Shape stemp = Shape(pos[j],size[j],colour[j],shapeType[j]);
			dst = opSmoothUnion(GetShapeDistance(p,s),GetShapeDistance(p,stemp),1.0);
			if(dst<dstToScene){
				dstToScene=dst;
			}
		}
    }
    return dstToScene;
}

float signedDstToScene(vec3 p, inout vec3 col){
    float dstToScene = maxDst;
    Shape s;
    float dst;
    for(int i = 0; i < maxObj; i++){
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
    float dstToScene = maxDst;
    Shape s;
	float dst;
    for(int i = 0; i < maxObj; i++){
        s = Shape(pos[i],size[i],colour[i],shapeType[i]);
        dst = GetShapeDistance(p,s);
		if(dst<dstToScene){
            dstToScene=dst;
        }
    }
    return dstToScene;
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
            
			for(int i = 0; i < lightspos.length(); i++){
				vec3 lightPos = vec3(lightspos[i].x,lightspos[i].y,lightspos[i].z);
				vec3 lightIntensity = vec3(lightsintensity[i].x,lightsintensity[i].y,lightsintensity[i].z);
				color += phongContribForLight(k_d, k_s, alpha, p, eye, lightPos, lightIntensity) * 0.4545;
			}
            return color;
        }

float calcSoftshadow( in vec3 ro, in vec3 rd, float mint, float maxt, float k )
{
    float res = 1.0;
    float ph = 1e20;
    for( float t=mint; t<maxt; )
    {
        float h = signedDstToScene(ro + rd*t);
        if( h<0.0001 )
            return 0.0;
        float y = h*h/(2.0*ph);
        float d = sqrt(h*h-y*y);
        res = min( res, k*d/max(0.0,t-y) );
        ph = h;
        t += h;
    }
    return res;
}

float shadow(vec3 ro, vec3 rd, float mint, float maxt){
	
    for (float t = mint; t < maxt;)
    {
        float h = signedDstToScene(ro+rd*t);
        if (h < 0.001)
            return 0.0;
        t += h;
    }
    return 1.0;
}



void main() {
    c = createCamera(camPos,lookAt);
    Ray r = Ray(c.Pos,GetPoint(c));
    float rayDst = 0.0;
    float circleSize;
    float closestDst = maxDst;
    int iterations = 0;
    float step = 0.0;
    vec3 shapeCol;
    
        while(rayDst < maxDst)
        {
			iterations++;
			#ifdef FRACTALS
				circleSize = Sierpinski2(r.origin);
			#else
				circleSize = signedDstToScene(r.origin);
			#endif
            if(circleSize < minDst) 
            {
				
				circleSize = signedDstToScene(r.origin,shapeCol);
				vec4 outcolor = vec4(phongIllumination(k_a,shapeCol,k_s,shininess,r.origin,c.Pos),1.0);
				for(int i = 0; i < lightspos.length(); i++)
				{
					vec3 lp = lightspos[i];
					Ray rTemp = Ray(r.origin,normalize(lp - r.origin));
					//r.direction = normalize(lp - r.origin);
					//float shadowScale = calcSoftshadow(rTemp.origin,rTemp.direction,1.0,100.0,16.0);
					float shadowScale = shadow(rTemp.origin,rTemp.direction,1.0,100.0);
					outcolor.xyz *= shadowScale;
				}
				//outcolor.xyz*=vec3((step/10.0),(step/10.0),(step/10.0));
                gl_FragColor = outcolor;
                //gl_FragColor=vec4(1.0,1.0,1.0,1.0);
                //gl_FragColor=vec4(1.0-(step/100.0),0.0,0,1.0);
                //gl_FragColor=vec4(r.origin.x,r.origin.y,r.origin.z,1.0);
                //gl_FragColor*=vec4(1.0-(step/200.0),1.0-(step/200.0),1.0-(step/200.0),1.0);
                //gl_FragColor=vec4(shapeCol,1.0);
				return;
            }
			else{
				r.origin += r.direction * circleSize;
				rayDst += circleSize;
				closestDst=min(closestDst,circleSize);
				step++;
			}
        }
    
    //gl_FragColor+=vec4(10.0/closestDst/10.0,10.0/closestDst/10.0,10.0/closestDst/10.0,1.0);
    //gl_FragColor=vec4(r.direction.x/closestDst,r.direction.y/closestDst,r.direction.z/closestDst,1.0);
    gl_FragColor=vec4(0.0,0.3,0.6,1.0);
    //gl_FragDepth=u_mouse.x;
}
