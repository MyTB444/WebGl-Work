// ECS610U -- Miles Hansard

precision highp float;

uniform mat4 modelview, modelview_inv, projection, view_inv;

uniform struct {
    vec4 position, ambient, diffuse, specular;  
} light;

vec4 gamma_transform(vec4 colour, float gamma) {
    return vec4(pow(colour.rgb, vec3(gamma)), colour.a);
}
uniform bool render_skybox, render_texture;
uniform samplerCube cubemap;
uniform sampler2D texture;
uniform float canvas_width;
float width = 850.0;
vec3 base = vec3(1.0); // used for capturing vignette alone

float vignette(vec2 fragCoord) {
    vec2 uv = fragCoord / vec2(width, width);
    vec2 p  = uv * 2.0 - 1.0;          // centre at (0,0)
    float r = length(p);
    float vmin = 0.1;
    float s = smoothstep(0.6, 1.0, r); // inner and outer radius
    return 1.0 - (1.0 - vmin) * s;
}

varying vec2 map;
varying vec3 d, m;
varying vec4 p, q;

void main()
{ 
    vec3 n = normalize(m);

    if(render_skybox) {
        gl_FragColor = textureCube(cubemap,vec3(-d.x,d.y,d.z));
        //float v = vignette(gl_FragCoord.xy);
        //gl_FragColor = vec4(base * v, 1.0);
        gl_FragColor.rgb *= vignette(gl_FragCoord.xy);


    }
    else {

        // object colour
        vec4 material_colour = texture2D(texture,map);
        //material_colour.rgb = 1.0 - material_colour.rgb;    // reverse the rgb
        //float d = length(material_colour.rgb);          
        //material_colour.a = (d < 0.7) ? 0.0 : 1.0;      

        //if (!gl_FrontFacing) {
        //discard;
        //}
        //float gamma_value = 0.5;
        //float gamma_value = 2.0;
        // apply gamma only on right half of canvas
        //if (gl_FragCoord.x > canvas_width / 2.0) {
        //   material_colour = gamma_transform(material_colour, gamma_value);
        //}

        // sources and target directions 
        vec3 s = normalize(q.xyz - p.xyz);
        vec3 t = normalize(-p.xyz);

        // reflection vector in world coordinates
        vec3 r = (view_inv * vec4(reflect(-t,n),0.0)).xyz;

        // reflected background colour
        vec4 reflection_colour = textureCube(cubemap,vec3(-r.x,r.y,r.z));

        // blinn-phong lighting

        vec4 ambient = material_colour * light.ambient;
        vec4 diffuse = material_colour * max(dot(s,n),0.0) * light.diffuse;

        // halfway vector
        vec3 h = normalize(s + t);
        vec4 specular = pow(max(dot(h,n), 0.0), 4.0) * light.specular;       

        // combined colour
        if(render_texture) {
            // B2 -- MODIFY
            gl_FragColor = vec4((0.5 * ambient + 
                                 0.5 * diffuse + 
                                 0.01 * specular + 
                                 0.1*reflection_colour).rgb, 1.0); 

        }
        else {
            // reflection only 
            gl_FragColor = reflection_colour;

        }
        gl_FragColor.rgb *= vignette(gl_FragCoord.xy);
        //float v = vignette(gl_FragCoord.xy);
        //gl_FragColor = vec4(base * v, 1.0);
        //gl_FragColor.rgb *= 0.5;
    }
}

