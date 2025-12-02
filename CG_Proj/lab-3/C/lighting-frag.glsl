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

const float PI = 3.14159265;

vec3 hsv_to_rgb(vec3 c) {
    vec4 k = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
    return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
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

    float angle = atan(n.y, n.x);                      
    float hue   = (angle + PI) / (2.0 * PI);           

    float saturation = 1.0 - abs(n.z);                
    float modified_saturation = pow(saturation, 0.5); 

    vec3 hsv = vec3(hue, modified_saturation, 1.0);
    vec3 rgb = hsv_to_rgb(hsv);

    float z = scene_depth(gl_FragCoord.z);

    float g = (far - z) / (far - near);
    g = clamp(g, 0.0, 1.0);
    
    vec3 s_n = normalize(s);
    vec3 t_n = normalize(t);

    vec3 fragment_rgb = material.ambient.rgb + material.diffuse.rgb;

    float ndotl = max(dot(s_n, n), 0.0);
    float vdotn = dot(t_n, n);
    
    //if (ndotl > 0.9) {
    //    fragment_rgb += material.specular.rgb;
    //} else if (ndotl > 0.75) {
    //    fragment_rgb += 0.2 * material.specular.rgb;
    //}
    //if (vdotn < 0.4) {
    //  fragment_rgb = 0.3 * material.diffuse.rgb;
    //}

    //D3 work below

    // 3 separate layers of shade
    float shade;
    if (ndotl > 0.7)
        shade = 1.0;
    else if (ndotl > 0.3)
        shade = 0.6;
    else
        shade = 0.25;


    // adds fading light surrounding the head
    if (vdotn < 0.3) {
        gl_FragColor = vec4(0.2, 0.4, 1.0, 1.0);  // blue rim
    } else {
        vec3 base = material.diffuse.rgb * shade;
        gl_FragColor = vec4(base, 1.0);
    }

    //gl_FragColor = vec4(fragment_rgb, 1.0);
    //gl_FragColor = vec4(vec3(g), 1.0);
    //gl_FragColor = vec4((ambient + diffuse + specular).rgb, 1.0);
    //gl_FragColor = vec4(rgb, 1.0);
}

