// CircleGrid infiller
// 2018-06-14
// by Jimmy Etienne and Salim Perchy

int numPasses = 3; // tells the render the number of required passes
uniform int u_Pass; // pass being rendered: 0,1,...,numPasses-1

#define initial_radius 2.0
  
vec4 cellular (vec3 world)
{
  float d = max(density(world) / 100.0, 10.0/100.0);

  float radius = initial_radius / d;
  float radius_2 = radius * (sqrt(2.0) - 1.0);
  float radius_3 = radius_2 * (sqrt(2.0) - 1.0) / sqrt(2.0);
  
  if (u_Pass == 0) {
    int xid = int(floor(world.x / (2.0*radius)));
    int yid = int(floor(world.y / (2.0*radius)));
    vec2 center = vec2( float(xid) * 2.0 * radius + radius, float(yid) * 2.0 * radius + radius);
    float dist = length(world.xy - center) + 0.1;

    if (dist < radius) {
      return vec4(1.0, 0.0, 0.0, 0.0); 
    }
  } else if (u_Pass == 1) {
    int xid = int(round(world.x / (2.0*radius)));
    int yid = int(round(world.y / (2.0*radius)));

    vec2 center = vec2( float(xid) * 2.0 * radius, float(yid) * 2.0 * radius);
    float dist = length(world.xy - center);

    if (dist < radius_2) {
      return vec4(0.0, 1.0, 0.0, 0.0); 
    }
  } else if (u_Pass == 2) {
    int xid = int(round(world.x / (2.0*radius)));
    int yid = int(round(world.y / (2.0*radius)));

    vec4 x = vec4 (-1.,1.,0.,0.);
    vec4 y = vec4 (0.,0.,-1.,1.);

    for (int i = 0; i < 4; i++) {
      vec2 center = vec2( float(xid) * 2.0 * radius + x[i] * (radius_2 + radius_3),
      float(yid) * 2.0 * radius + y[i] * (radius_2 + radius_3));
      float dist = length(world.xy - center);

      if (dist < radius_3) {
        return vec4(0.0,0.0,1.0,1.0); 
      }
    }
  }
  return vec4(0.0); 
}