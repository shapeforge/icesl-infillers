// Gyroid infiller
// 2019-02-05
// by Jimmy Etienne
//
// This file is under MIT license
//
// Quick example of custom infiller for IceSL
//
// Gyroid infiller for IceSL
//
// ShaderToy version: https://www.shadertoy.com/view/WstGWf

vec4 gyroid (vec3 pos) {
    float coef = 1.0/(40.0 * nozzle_diameter());
    pos *= density(pos)*coef;
    float v = dot(sin(pos),cos(pos.yzx));
    return v > 0. ? vec4(1,0,0,1) : vec4(0,0,1,1);
}

vec4 cellular( vec3 world ) {    
  mat3 rot;
  rot[0] = vec3(cos(45.), -sin(45.), 0.);
  rot[1] = vec3(sin(45.),  cos(45.), 0.);
  rot[2] = vec3(      0.,        0., 1.);
	return gyroid(rot * world);
}
