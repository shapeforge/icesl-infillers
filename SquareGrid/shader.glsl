// SquareGrid infiller
// 2018-06-11
// by Sylvain Lefebvre
//
// This file is under MIT license
//
// Quick example of custom infiller for IceSL
//
// Produces a checkerboard infill by interleaving two
// sets of line.
//
// Will only work reasonably using constant density.

int numPasses = 2; // tells the render the number of required passes
uniform int u_Pass; // pass being rendered: 0,1,...,numPasses-1

vec4 cellular( vec3 world )
{
  float d = density(world) / 100.0;
  int xid = int(floor(world.x / (10.0-d*8.0)));
  int yid = int(floor(world.y / (10.0-d*8.0)));
  if (u_Pass == 0) {
    return vec4(float(xid & 1),0.0,0.0,0.0);
  } else {
    return vec4(float(yid & 1),0.0,0.0,0.0);
  }  
}
