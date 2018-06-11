# icesl-infillers

### This feature is in beta and subject to change.

Infillers are special shaders (in GLSL) that can be used to create your own infill patterns in IceSL.

The idea is to describe the infill as 'colored' cells. The infill paths are then extracted as the boundary of the colored cells (and thus have a width of exactly one nozzle). This is a verstaile approach that can be used to describe many infills, from regular to irregular and foam-like structures. Furthermore, this can be used to create variable infills and even deform the infills by changing the input coordinates (warping).

The infills can be produced in multiple passes, so as to ensure better continuity (e.g. the Checkboard example is done in two passes
to produce two sets of crossing lines instead of all the checkerboard square segments).

The shaders have access to the infill density parameter (constant, per-layer or field). 
Access to other fields will be added in the future.

The shaders have to implement the following function:
```glsl
vec4 cellular( vec3 world )
```

This takes as input a 3d point (in millimeters) using world space coordinates (coordinates from the printing bed setup).
The return value is a color (RGBA) for each cell. It is essential for neighboring cells to have different colors, otherwise no path will be produced between them.

The shader can optionally specify a number of passes:
```glsl
int numPasses = 2; // number of required passes
```

The shader will receive the current pass being processed by declaring a uniform:
```glsl
uniform int u_Pass; // pass being rendered: 0,1,...,numPasses-1
```

The density field can be accessed as follows:
```glsl
float d = density(world);
```
This returns the density at point 'world'. Keep in mind this will be either constant, varying per-layer or controlled by a field.
The returned value is in [0,100] (percentage). The shader can interpret it freely ; but of course users expect it to represent a percentage of volume within the part.

Each infiller is a single file named "shader.glsl" stored in a subdirectory of icesl-infillers. These are automatically loaded into the UI. The icesl-infillers directory should be in %appdata%\IceSL (Windows) or ~/.icesl (Linux).

This is meant as a research tool, but we are hoping to see some fancy infills being contributed! Feel free to ask for pull requests.
