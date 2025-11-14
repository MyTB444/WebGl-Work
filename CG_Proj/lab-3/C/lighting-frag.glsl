// ECS610U -- Miles Hansard 2020

precision mediump float;

// light data
uniform struct {
    vec4 position, ambient, diffuse, specular;  
} light;

// material data
uniform struct {
    vec4 ambient, diffuse, specular;
    float shininess;
} material;

// clipping plane depths
uniform float near, far;

// normal, source and taget -- interpolated across all triangles
varying vec3 m, s, t;


void main()
{   
    // renormalize interpolated normal
    vec3 n = normalize(m);

    // reflection vector

    // phong shading components

    vec4 ambient = material.ambient * 
                   light.ambient;

    vec4 diffuse = material.diffuse * 
                   max(dot(s,n),0.0) * 
                   light.diffuse;

    // B1 -- IMPLEMENT SPECULAR TERM
    // direction to light and to viewer
    vec3 l = normalize(s);
    vec3 v = normalize(t);

    // B3 -- IMPLEMENT BLINN SPECULAR TERM
    // half-vector between light and view
    vec3 h = normalize(l + v);

    float specFactor = pow(max(dot(n, h), 0.0),
                           material.shininess * 4.0);
    vec4 specular = material.specular *
                    specFactor *
                    light.specular;
    

    gl_FragColor = vec4((ambient + diffuse + specular).rgb, 1.0);
}

