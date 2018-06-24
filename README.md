# icesl-infillers

### This feature is in beta and subject to change.

Infiller shaders answer the problem of designing custom infill patterns. This is useful for customizing the infill for a specific part, for infill research, and for coming up with fun, interesting fill patterns!

A difficulty in designing your own infill is how to specify the paths themselves. Indeed, infill patterns are usually made of single deposition tracks, so specifying them as volume meshes or implicit volumes does not work well. In addition, the infill pattern may involve several crossing deposition tracks, and potentially varies according to e.g. a specified density field (to increase/decrease the fill percentage locally within the part).

Our answer to this problem are infiller shaders. These are shaders (in GLSL) that can be used to create your own infill patterns in IceSL.

The idea is to describe the infill as colored cells, where a cell simply is a connected region having a same color. The color itself does not matter. What matters are the /boundaries/ between the cells. These are extracted and become the infill pattern paths. The figure below illustrates this idea.



This is a versatile approach that can be used to describe many infill patterns, from regular to irregular and foam-like structures. In addition, this can be used to create a variable infill and even deform an existing infill by changing the input coordinates (warping).

An infill can be produced in multiple passes, so as to produce crossing continuous paths. Each pass is done independently, and paths are extracted before going to the next pass.

An infill shaders has access to the infill percentage parameter (constant, per-layer or field). 
Access to other fields will be added in the future.

The shader has to implement the following function:
```glsl
vec4 cellular( vec3 world )
```

This takes as input a 3d point (in millimeters) using world space coordinates (coordinates from the printing bed setup). The return value is a color (RGBA) for each cell. Again the color itself does not matter, what matters is that a frontier between two colors will produce a deposition path.

The shader can optionally specify a number of passes:
```glsl
int numPasses = 2; // number of required passes
```

The shader will receive the current pass being processed by declaring a uniform:
```glsl
uniform int u_Pass; // pass being rendered: 0,1,...,numPasses-1
```

The density field (infill percentage) can be accessed as follows:
```glsl
float d = density(world);
```
This returns the density at point 'world'. Keep in mind this will be either constant, varying per-layer or controlled by a field.
The returned value is in [0,100] (percentage). The shader can interpret it freely ; but of course users expect it to represent the percentage of infill volume within the part.

Each infiller is a single file named "shader.glsl" stored in a subdirectory of icesl-infillers. These are automatically loaded into the UI. The icesl-infillers directory should be in %appdata%\IceSL (Windows) or ~/.icesl (Linux).

This is meant as a research tool, but we are hoping to see some fancy infills being contributed! Feel free to ask for pull requests.
