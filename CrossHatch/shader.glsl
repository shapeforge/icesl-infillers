// Croshatch Infiller for IceSL

// The MIT License
// Copyright © 2024  Giovanni Cocco, Xavier Chermain
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


// For further information about this infill please see: https://www.allaboutbambu.com/2024/05/15/bambu-studio-has-a-new-crosshatch-infill/

// Shadertoy version : https://www.shadertoy.com/view/Xf2yR1


#define PI 3.1415926535

uniform float ui_infill_period_Z        = 1.0;  // Infill scaling in Z axis.
uniform float ui_infill_rotation_angle  = 45.0; // Infill orientation in degrees.
const int ui_infill_straight_line_multi = 2;    // Size of straight connecting sections. 

float evaluateSubcell(vec2 pos, float w)
{
	return (pos.y - (pos.x * 0.5 / w) - step(w, pos.x)) > 0.0 ? 1.0 : 0.0;
}

float evaluateCell(vec2 pos, float w)
{
    if (pos.y < 0.5) {
        if (pos.x < 0.5) {
           return evaluateSubcell(2.*pos, w);
        } else {
           return evaluateSubcell(2.*vec2((1.-pos.x), pos.y), w);
        }
    } else {
        if (pos.x < 0.5) {
           return evaluateSubcell(2.*vec2(pos.x, (1.-pos.y)), w);
        } else {
           return evaluateSubcell(2.*(1.-pos.xy), w);
        }
    }
}

int modP(int a, int b)
{
  int res = a % b;
  return res < 0 ? res + b : res;
}

vec4 crosshatch(vec3 pos, float period, float cellSize, int straightMultiplier)
{
	pos.z /= period;
	bool neg = pos.z < 0.0;
	if (neg) pos.z -= 1.0; // hack to void duplication of straight walls when going from negativo to positive pos.z
	int M = straightMultiplier;
	int layerCase = modP(int(pos.z), 2*M+4);
	if (layerCase >= M+1 && layerCase <= 2*M+2) {
		pos.xy = vec2(cellSize-pos.y, pos.x);
	}
	if (layerCase == M+1 || layerCase == 2*M+3) {
		pos.z = -fract(pos.z);
	}
	float w = fract(pos.z)*0.5;

	if (w == 0.0 && !neg && (layerCase == M+1 || layerCase == 2*M+3)) {
		w = 0.5;
	} else if (w == 0.0 && neg && (layerCase == M || layerCase == 2*M+2)) {
		w = 0.5;
	}

	if (layerCase < M || (layerCase >= M+2 && layerCase <= 2*M+1)) {
		w = 0.;
	}

	float isEven = float(modP(int(dot(vec2(1), floor(pos.xy/cellSize))), 2));
	float val = isEven*evaluateCell(fract(pos.xy/cellSize), w);
	bool isInverted = modP(int(floor(pos.x/cellSize)), 2) == 0;
	if (isInverted) {
	   val = abs(val-1.);
	}
	return vec4(val);
}

float get_cell_side_length_xy(vec3 world)
{
	return 125 * nozzle_diameter() / density(world);
}

vec4 cellular(vec3 world)
{
	float period = ui_infill_period_Z;
	// period = 125 * nozzle_diameter() / density(world); // this loses independence of the Z axis scale
	float cellSize = get_cell_side_length_xy(world);
	int straightMultiplier = ui_infill_straight_line_multi;

	float angle = ui_infill_rotation_angle/180.*PI;
	float c = cos(angle), s = sin(angle);
	mat3 rot45 = mat3(c, s, 0, -s, c, 0, 0, 0, 1);
	return crosshatch(rot45 * world, period, cellSize, straightMultiplier);
}