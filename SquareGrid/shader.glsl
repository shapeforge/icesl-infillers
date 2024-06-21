// SquareGrid infiller
// 2018-06-24
// by Sylvain Lefebvre and Salim Perchy
//
// This file is under MIT license
//
// Quick example of custom infiller for IceSL
//
// Produces a square grid
// 
// ShaderToy version: https://www.shadertoy.com/view/MdGBRt

bool isEven(int n)
{
    return n - (n/2)*2 == 0;
}

//////////////////////////////////////////
const int numPasses = 2; // number of passes
uniform int u_Pass;	     // current pass: 0,1,...,numPasses-1

uniform float ui_colWidth = 2.0;    // Grid column width (mm)
uniform float ui_rowWidth = 2.0;    // Grid row height (mm)

vec4 cellular( vec3 world )
{
    float coef = 1.0/(100.0 * nozzle_diameter());
    float d = max(density(world),1.0) * coef;              // normalized density (%)
    
    if (u_Pass == 0) {				                       // first pass: create the grid's columns
        float colSpacing = ui_colWidth / d;                // column width wrt density (mm)
        int column = int(floor(world.x / colSpacing));
        if (isEven(column)) {
            return vec4(1,0,0,1);                          // even columns are red
        } else {
            return vec4(0);                                // odd columns are colorless
        }
    } else {
        float rowSpacing = ui_rowWidth / d;                // second pass: create the grid's rows
        int row = int(floor(world.y / rowSpacing));        // rom height wrt density (mm)
        if (isEven(row)) {
            return vec4(0,1,0,1);                          // even rows are blue
        } else {
            return vec4(0);                                // odd rows are colorless
        }
    }
}
//////////////////////////////////////////
