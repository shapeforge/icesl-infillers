// Honeycomb infiller
// 2018-06-27
// by Jimmy Etienne and Salim Perchy
//
// This file is under MIT license
//
// Quick example of custom infiller for IceSL
//
// Honeycomb infiller for IceSL
//
// ShaderToy version: https://www.shadertoy.com/view/MsVfzd

bool isEven(int n)
{
  return (n - 2 * (n / 2)) == 0  ;
}

//////////////////////////////////////////
#define S 4.0
#define ratio sqrt(3.0)/3.0

const int numPasses = 1; // tells the render the number of required passes
uniform int u_Pass;      // pass being rendered: 0,1,...,numPasses-1

vec4 cellular( vec3 world )
{    
  float coef = 1.0/(90.0 * nozzle_diameter());
  float d = density(world) * coef;
  float X = S * ratio / d; float Y = S / d;
  
  float r = round(world.y / Y); // row
  float c = round(world.x / X); // column
      
  float r2 = floor(world.y / Y); // lower row
  float c2 = floor(world.x / X); // lower column
      
  vec2 p1 = vec2 ( c * X, r * Y); // first closest point
  vec2 p2 = vec2 ( c2 * X + X / 2.0, r2 * Y + Y / 2.0); // second closest point

  // Voronoi diagram (4 colors)
  if ( length(world.xy - p1) < length(world.xy - p2) ) {
    if ( isEven(int(c)) ) {
      return vec4(1.0, 0.0, 0.0, 1.0);
    } else {
      return vec4(1.0, 0.5, 0.0, 1.0);
    }
  } else {
    if ( isEven(int(c2)) ) {
      return vec4(0.0, 1.0, 0.0, 1.0);
    } else {
      return vec4(0.0, 0.5, 1.0, 1.0);
    }
  }
}
//////////////////////////////////////////
