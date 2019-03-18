// TriangleGrid infiller
// 2018-06-14
// by Salim Perchy
//
// This file is under MIT license
//
// Quick example of custom infiller for IceSL
//
// Produces a square grid
// 
// ShaderToy version: https://www.shadertoy.com/view/lsGBRt


bool isEven( int n )
{
    return (n-(n/2)*2) == 0;
}

//////////////////////////////////////////
#define PI 3.1415926535897932384626433832795
#define tX 1.0
#define tY 2.0
// tX and tY are in mm
//
//   _____tX_____
//  |\Ang       /
//  | \        /
//  |  \      e
//  tY  a    /
//  |    \  /
//  |  90o\/ 
//  |     / h
//  |    /
//  |   d
//  |  /
//  | /
//  |/

const float h = sqrt(pow(tX,2.0) + pow(tY,2.0));
const float a = tX * tY / h;
const float d = pow(tY,2.0) / h;
const float e = pow(tX,2.0) / h;

const float sin_ang = e / tX;
const float cos_ang = a / tX;

const mat4  mRotAng1 = mat4( // Z-rotation matrix by Ang
    cos_ang,-sin_ang,0,0,
    sin_ang, cos_ang,0,0,
          0,       0,1,0,
	        0,       0,0,1);
const mat4  mRotAng2 = mat4( // Z-rotation matrix by -Ang
    cos_ang, sin_ang,0,0,
   -sin_ang, cos_ang,0,0,
          0,       0,1,0,
	        0,       0,0,1);
			
//////////////////////////////////////////
const int numPasses = 3; // number of passes
uniform int u_Pass;      // current pass: 0,1,...,numPasses-1

vec4 cellular( vec3 world )
{
    float coef = 1.0/(160.0 * nozzle_diameter());
    float d = max(density(world),1.0) * coef;		     	  // normalized density
    if (u_Pass == 0) {       							                // first pass: create rows
        float rowSpacing = tY / d;                        // row height wrt density
    	int row = int(floor(world.y / rowSpacing));
    	if (isEven(row)) {
	        return vec4(1,0,0,1);						                // even rows are red
    	} else {
        	return vec4(0);       						              // odd rows are colorless
    	}
    } else if (u_Pass == 1) { 							              // second pass: create positive diagonals (i.e., /)
        float diagonalSpacing = 2.0 * a / d;	            // diagonal size wrt density
        vec4 worldTransformed = vec4(world,1) * mRotAng1; // point transformed to ease calculation of diagonal group
        int diag = int(floor(worldTransformed.x / diagonalSpacing));
        if (isEven(diag)) {
            return vec4(0,1,0,1);						              // even positive diagonal groups are green
        } else {
            return vec4(0);								                // odd positive diagonal groups are colorless
        }
    } else if (u_Pass == 2) {							                // third pass: create negative diagonals (i.e., \)
        float diagonalSpacing = 2.0 * a / d;              // diagonal size wrt density
        vec4 worldTransformed = vec4(world,1) * mRotAng2; // point transformed to ease calculation of diagonal group
        int diag = int(floor(worldTransformed.x / diagonalSpacing));
        if (isEven(diag)) {
            return vec4(0,0,1,1);						              // even negative diagonal groups are blue
        } else {
            return vec4(0);								                // odd negative diagonal groups are colorless
        }
    }
}
//////////////////////////////////////////
