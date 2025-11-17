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

float scene_depth(float frag_z)
    {
        float ndc_z = 2.0*frag_z - 1.0;
        return (2.0*near*far) / (far + near - ndc_z*(far-near));
    }


void main()
{   
    //if(gl_FragCoord.z < 0.5) {
        // don't render close fragments
     //   discard;
   // }
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

    float specFactor = pow(abs(dot(n, h)),
                           material.shininess);
    vec4 specular = material.specular *
                    specFactor *
                    light.specular;

    //float z = scene_depth(gl_FragCoord.z);

    //float g = (far - z) / (far - near);
    //g = clamp(g, 0.0, 1.0);

    //gl_FragColor = vec4(vec3(g), 1.0);

    gl_FragColor = vec4((ambient + diffuse + specular).rgb, 1.0);
}

