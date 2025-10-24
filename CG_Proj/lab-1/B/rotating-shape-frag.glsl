precision mediump float;
varying lowp vec4 colour_var;


void main()
{
    // A2 & A4: MODIFY BELOW
    vec3 red = vec3(1.0,0.0,0.0);
    vec3 blue = vec3(0.0,0.0,1.0);
    vec3 green = vec3(0.0,1.0,0.0);

    //gl_FragColor = vec4(red + green, 1.0);
     gl_FragColor = colour_var;
}

