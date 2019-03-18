// CircleGrid infiller
// 2018-06-14
// by Jimmy Etienne and Salim Perchy
//
// This file is under MIT license
//
// Quick example of custom infiller for IceSL
//
// Produces a square grid
// 
// ShaderToy version: https://www.shadertoy.com/view/MsGBRt

//////////////////////////////////////////
#define initial_radius 2.0
#define depth 3             // depth of circle hierarchy, possible values; 1,2,3

const int numPasses = 1;    // number of passes
uniform int u_Pass;         // current pass: 0,1,...,numPasses-1

vec4 cellular (vec3 world)
{
  float coef = 1.0/(150.0 * nozzle_diameter());
  float d = max(density(world),1.0) * coef;

  float radius   = initial_radius / d;
  float radius_2 = radius * (sqrt(2.0) - 1.0);
  float radius_3 = radius_2 * (sqrt(2.0) - 1.0) / sqrt(2.0);

  int xid  = int(floor(world.x / (2.0*radius)));
  int yid  = int(floor(world.y / (2.0*radius)));

  int xidr = int(round(world.x / (2.0*radius)));
  int yidr = int(round(world.y / (2.0*radius)));

  if (depth > 0) { // bigger circles

    vec2 center = vec2( float(xid) * 2.0 * radius + radius, float(yid) * 2.0 * radius + radius);
    float dist  = length(world.xy - center) + 0.1;
    if (dist < radius) {
      return vec4(1.0, 0.0, 0.0, 0.0); 
    }
  }
  if (depth > 1) { // medium circles

    vec2 center = vec2( float(xidr) * 2.0 * radius, float(yidr) * 2.0 * radius);
    float dist  = length(world.xy - center);

    if (dist < radius_2) {
      return vec4( 0.0, 1.0, 0.0, 0.0 );
    }
  }
  if (depth > 2) { // small circles

    vec4 x = vec4 (-1.0, 1.0, 0.0, 0.0 );
    vec4 y = vec4 ( 0.0, 0.0,-1.0, 1.0 );

    for (int i = 0; i < 4; i++) {
      vec2 center = vec2( float(xidr) * 2.0 * radius + x[i] * (radius_2 + radius_3),
      float(yidr) * 2.0 * radius + y[i] * (radius_2 + radius_3));
      float dist = length(world.xy - center);

      if (dist < radius_3) {
        return vec4( 0.0, 0.0, 1.0, 1.0 );
      }
    }
  }
  return  vec4(0);
}
//////////////////////////////////////////
