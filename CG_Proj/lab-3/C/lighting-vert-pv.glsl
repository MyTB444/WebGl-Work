// ECS610U -- Miles Hansard 2020

precision mediump float;

attribute vec3 vertex;
attribute vec3 normal;

uniform mat4 modelview;
uniform mat4 projection;

// light data
uniform struct {
    vec4 position, ambient, diffuse, specular;  
} light;

// material data
uniform struct {
    vec4 ambient, diffuse, specular;
    float shininess;
} material;

// colour to pass to fragment shader
varying vec4 colour;

void main()
{
    // transform vertex to eye space
    vec4 pos_eye = modelview * vec4(vertex, 1.0);

    // transform normal to eye space
    vec3 n = normalize(mat3(modelview) * normal);

    // light & view directions (eye at origin)
    vec3 s = normalize(light.position.xyz - pos_eye.xyz); 
    vec3 v = normalize(-pos_eye.xyz);                     
    vec3 h = normalize(s + v);                          

    // Phong/Blinn components
    vec4 ambient = material.ambient * light.ambient;
    vec4 diffuse = material.diffuse * max(dot(s, n), 0.0) * light.diffuse;

    float specFactor = pow(max(dot(n, h), 0.0), material.shininess);
    vec4 specular = material.specular * specFactor * light.specular;

    // per-vertex colour for interpolation
    colour = ambient + diffuse + specular;

    // final clip-space position
    gl_Position = projection * pos_eye;
}
