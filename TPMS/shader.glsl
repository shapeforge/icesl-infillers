
// TPMS Class infiller
// 2024-09-05
// by Jonàs Martinez, Pierre-Alexandre Hugron, Eric Garner and Salim Perchy
//
// This file is under MIT license
//
// Family of TPMS (Triply Periodic Minimal Surface)
// class of infillers:
// 0. Gyroid
// 1. Schwarz P ("Primitive")
// 2. Schwarz D ("Diamond")
// 3. Neovius (see https://en.wikipedia.org/wiki/Neovius_surface)
// 4. Split-P (see https://www.researchgate.net/publication/353504299_A_multiscale_optimisation_method_for_bone_growth_scaffolds_based_on_triply_periodic_minimal_surfaces)
// 5. Lidinoid (see https://en.wikipedia.org/wiki/Lidinoid)

#define PI     3.1415926535
 
uniform float ui_cell_side_ratio_xy_z  = 1.0;  // Scaling factor w.r.t. Z axis. Warning, print cannot be guaranteed to be self supported with some values.
uniform float ui_infill_rotation_angle = 0.0;  // Rotation angle w.r.t. Z axis

uniform int ui_infill_type = 0; // Infill class:\n\n0. Gyroid\n1. Schwarz P ("Primitive")\n2. Schwarz D ("Diamond")\n3. Neovius\n4. Split-P\n5. Lidinoid


float get_cell_side_length_xy(vec3 world)
{
    return 250 * nozzle_diameter() / density(world);
}

mat2 rotationMatrix(float angle)
{
    angle *= PI / 180.0;
    float sine = sin(angle), cosine = cos(angle);
    return mat2( cosine, -sine, 
                 sine,    cosine );
}

// approximate implicit form Schoen Gyroid
float schoen_gyroid(vec3 p)
{
    return sin(p.x) * cos(p.y) + sin(p.y) * cos(p.z) + sin(p.z) * cos(p.x);
}

// approximate implicit form Schwarz P ("Primitive")
float schwarz_primitive(vec3 p)
{
    return cos(p.x) + cos(p.y) + cos(p.z);
}

// approximate implicit form Schwarz D ("Diamond")
float schwarz_diamond(vec3 p)
{
    return sin(p.x) * sin(p.y) * sin(p.z) + sin(p.x) * cos(p.y) * cos(p.z) + cos(p.x) * sin(p.y) * cos(p.z) + cos(p.x) * cos(p.y) * sin(p.z);
}

// approximate implicit form Neovius TPMS (see https://en.wikipedia.org/wiki/Neovius_surface)
float neovius(vec3 p)
{
    return 3.0 * (cos(p.x) + cos(p.y) + cos(p.z)) + 4 * (cos(p.x) * cos(p.y) * cos(p.z));
}

// see https://www.researchgate.net/publication/353504299_A_multiscale_optimisation_method_for_bone_growth_scaffolds_based_on_triply_periodic_minimal_surfaces
float split_p(vec3 p)
{
    return 1.1*(sin(2*p.x)*cos(p.y)*sin(p.z) + sin(2*p.y)*cos(p.z)*sin(p.x) + sin(2*p.z)*cos(p.x)*sin(p.y)) - 0.2*(cos(2*p.x)*cos(2*p.y) + cos(2*p.y)*cos(2*p.z) + cos(2*p.z)*cos(2*p.x)) - 0.4*(cos(2*p.y) + cos(2*p.z) + cos(2*p.x));
}

// see https://en.wikipedia.org/wiki/Lidinoid
float lidinoid(vec3 p)
{
    return 0.5 * sin(2*p.x) * cos(p.y) * sin(p.z) + sin(2*p.y) * cos(p.z) * sin(p.x) + sin(2*p.z) * cos(p.x) * sin(p.y) - cos(2*p.x) * cos(2*p.y) - cos(2*p.y) * cos(2*p.z) - cos(2*p.z) * cos(2*p.x) + 0.15;
}


vec4 cellular(vec3 world)
{
    float cell_side_length_xy = get_cell_side_length_xy(world);
    vec3 cell_side_length = vec3(cell_side_length_xy, cell_side_length_xy, cell_side_length_xy * ui_cell_side_ratio_xy_z);
    float value = 0;
    vec3 world_rot = vec3(world.xy * rotationMatrix(ui_infill_rotation_angle), world.z);
    if (ui_infill_type == 0)
        value = schoen_gyroid(2.0 * PI / cell_side_length * world_rot);
    else if (ui_infill_type == 1)
        value = schwarz_primitive(2.0 * PI / cell_side_length * world_rot);
    else if (ui_infill_type == 2)
        value = schwarz_diamond(2.0 * PI / cell_side_length * world_rot);
    else if (ui_infill_type == 3)
        value = neovius(2.0 * PI / cell_side_length * world_rot);
    else if (ui_infill_type == 4)
        value = split_p(2.0 * PI / cell_side_length * world_rot);
    else// if (ui_infill_type == 5)
        value = lidinoid(2.0 * PI / cell_side_length * world_rot);
 
    return value > 0.0 ? vec4(1,0,0,1) : vec4(0,0,1,1);
}