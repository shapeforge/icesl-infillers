// Simple Rectiliear infiller
// 2022-04-05
// by Pierre Bedell
//
// This file is under MIT license
//
// Quick example of custom infiller for IceSL
//
// SimpleRectilinear innfiller for IceSL
//
// Produces a rectilinear infill pattern
// which alternates at each z change
// 
// You can preview it in https://www.shadertoy.com/new
// (copy-paste, and un-comment the shadertoy #define)

//#define SHADERTOY

const float spacing = 2.0;
const float global_angle = 0.0; // global rotation angle in degree

//////////////////////////////////////////

// for shadertoy
#ifdef SHADERTOY
// Simulate IceSL's infill percentage parameter
float density(vec3 world)
{
	return 20.0;
}

// Simulate IceSL's nozzle diameter parameter
float nozzle_diameter()
{
    return 0.4;
}

// Simulate IceSL's layer heignt parameter
float layer_height()
{
    return 0.2;
}
#endif

//////////////////////////////////////////

bool isEven(int n)
{
    return n - (n/2)*2 == 0;
}

vec3 rotate(vec3 v, float angle)
{
    mat3 rot;
    rot[0] = vec3(cos(angle), -sin(angle), 0.);
    rot[1] = vec3(sin(angle), cos(angle), 0.);
    rot[2] = vec3(0., 0., 1.);

    return rot * v;
}

vec4 lines(vec3 pos)
{
    float coef = 1.0/(100.0 * nozzle_diameter());
    float d = max(density(pos),1.0) * coef; // normalized density (%)
    
    float s = spacing / d;
    float axis = isEven(int(pos.z / layer_height())) ? pos.x : pos.y;
    
    int line = int(floor(axis / s));
    
    // red if line is "even", otherwise blue
    return isEven(line) ? vec4(1,0,0,1) : vec4(0,0,1,1);
}

vec4 cellular( vec3 world )
{
    return lines(rotate(world, radians(global_angle)));
}

//////////////////////////////////////////

// for shadertoy
#ifdef SHADERTOY
// Renders infill over a 100mm x 100mm square
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = ( fragCoord - vec2(iResolution.x/2.0, iResolution.y/2.0) ) / min(iResolution.x, iResolution.y);
	// in IceSL, Z elevation is used instead of iTime
	vec3 world = vec3(uv * 100.0, iTime); // refresh display each second
    fragColor = cellular(world);
}
#endif
