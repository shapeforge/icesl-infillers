// Voro2D infiller
// 2018-06-24
// by Sylvain Lefebvre
//
// This file is under MIT license
//
// Quick example of custom infiller for IceSL
//
// Produces a vertical extrusion of a random 
// Voronoi diagram (e.g. Worley noise)
// Will only work reasonably using a constant density.
//
// ShaderToy version: https://www.shadertoy.com/view/XdKBzc

int numPasses = 1; // tells the render the number of required passes
int u_Pass; // pass being rendered: 0,1,...,numPasses-1

vec2 hash( int i, int j )
{
  ivec4 h = ivec4(i,j,i,j);
  for (int i=0;i<4;i++) {
    h = ivec4((h.y ^ (h.x*113))&65535, 
              (h.x ^ (h.w*8081))&65535,
              (h.w ^ (h.z*1471))&65535, 
              (h.z ^ (h.y*827))&65535);
  }
  return vec2( fract(float(h.x ^ (h.z*113))/11261.0), fract(float(h.y ^ (h.w*827))/18199.0) );
}

// --- end of noise functions

vec2 seed(float step,int i,int j)
{
  vec2 center = vec2( float(i)*step + 0.5 , float(j)*step + 0.5 );
  vec2 n = hash(i,j);
  return center + 0.707*(n-0.5)*step;
}

vec4 cellular( vec3 world )
{
  float coef = 1.0/(65.0 * nozzle_diameter());
  float d    = density(world) * coef;
  // density is interpreted as a step size for the
  // Voronoi seed grid, in mm
  float step = 10.0 - d*8.0; // from 2 to 10 mm
  // which grid cell are we in?
  int xid = int(floor(world.x / step));
  int yid = int(floor(world.y / step));
  // now produce (pseduo) random seeds in each grid cell
  // within a neighborhood and track closes
  ivec2 closest;
  float closest_dist = 1e9;
  for (int nj = yid-1 ; nj <= yid+1 ; nj ++) {
    for (int ni = xid-1 ; ni <= xid+1 ; ni ++) {
      vec2  s = seed(step,ni,nj);
      float d = length(s - world.xy);
      if (d < closest_dist) {
        closest_dist = d;          
        closest = ivec2(ni,nj);
      }
    }
  }
  // produce a random color from the seed  
  return vec4(hash(closest.x,closest.y),hash(closest.y,closest.x));
}
