// GLSL VERTEX SHADER

// 4x4 matrices
uniform mat4 pre_scale, pre_rotate, rotate, shear, projective;

uniform vec3 rgb;

// A2 -- DECLARE UNIFORM TRANSLATION MATRIX HERE

// xy coordinates are attributes -- different for each vertex
attribute vec4 vertex;

// colour for fragment shader
varying vec4 colour;

void main()
{
    // homogeneous cordinates [x,y,z,w]
    vec4 point =  vec4(vertex.x, vertex.y, 0.0, 1.0);

    // A3 -- DEFINE translate_inv HERE

    // A1 -- ADD CODE HERE

    // A1, A2, A3, A4, A5 -- MODIFY HERE
    gl_Position = point;

    // pass uniform colour to fragment shader varying
    // A5 -- MODIFY HERE
    colour = vec4(rgb, 1.0);
}
