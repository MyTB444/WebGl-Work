'use strict';
// HTML5 canvas, WebGL context, and shader filenames
var canvas, gl;
const vs_file = './rotating-shape-vert.glsl';
const fs_file = './rotating-shape-frag.glsl';

// rotation angle, and location in shader
var theta = 0.0;
var theta_loc;

// buffers and attributes
var vertices, indices, colours;
var index_buf, colour_buf;
var colour_loc;

// intialization --- called once per page load
window.onload = async function()
{
   // --- general setup ---

   // configure button to save the image
   capture_canvas_setup('gl-canvas', 'capture-button', 'capture.png');

   // prepare the GL context
   canvas = document.getElementById('gl-canvas');
   gl = canvas.getContext('webgl');
   
   // global window settings
   gl.viewport(0, 0, canvas.width, canvas.height);
   gl.clearColor(1.0, 1.0, 1.0, 1.0);

   // load the shader source code into JS strings
   const vs_src = await fetch(vs_file).then(out => out.text());
   const fs_src = await fetch(fs_file).then(out => out.text());
   // make the shaders and link them together as a program
   let vs = webgl_make_shader(gl, vs_src, gl.VERTEX_SHADER);
   let fs = webgl_make_shader(gl, fs_src, gl.FRAGMENT_SHADER);
   let program = webgl_make_program(gl, vs, fs);
   gl.useProgram(program);

    // --- geometry and colour data ---

    const num_vertices = 6;
    vertices = [[0,0]];
    for (let k = 0; k < num_vertices; k++) 
        {      
        const t = (k / num_vertices) * 2 * Math.PI;         
        vertices.push(Math.cos(t), Math.sin(t));           
    }
    indices = [0, 1, 2, 3, 4, 5, 6, 1];
    // B1: ADD CODE HERE

    // RGBA values for hexagon
    // B2: MODIFY THE COLOURS
    colours = [
        [0.0, 0.0, 0.0, 0.0],
        [1.0, 0.0, 0.0, 1.0],
        [1.0, 1.0, 0.0, 1.0],
        [0.0, 1.0, 0.0, 1.0],
        [0.0, 1.0, 1.0, 1.0],
        [0.0, 0.0, 1.0, 1.0],
        [1.0, 0.0, 1.0, 1.0]
    ];

    // --- geometry and colour setup ---

    // setup vertex array
    let vertex_buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vertex_buf);
    gl.bufferData(gl.ARRAY_BUFFER, mat_float_flat(vertices), gl.STATIC_DRAW);

    // connect vertex variable in shader to vertex_buf (the current ARRAY_BUFFER)
    let vertex_loc = gl.getAttribLocation(program, "vertex");
    gl.vertexAttribPointer(vertex_loc, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(vertex_loc);

    // setup vertex colours
    const colour_buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, colour_buf);
    gl.bufferData(gl.ARRAY_BUFFER, mat_float_flat(colours), gl.STATIC_DRAW);
    colour_loc = gl.getAttribLocation(program, 'colour');

    // note that colour_buf will remain the current ARRAY_BUFFER

    // setup edge indices
    index_buf = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, index_buf);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, mat_uint_flat(indices), gl.STATIC_DRAW);

    // get locations of uniform angle variable from the shader
    theta_loc = gl.getUniformLocation(program, "theta");

    // drawing style
    gl.lineWidth(5.0);

    // start drawing
    render();
};


// --- rendering function --- called once per frame

function render() {

    // clear the canvas
    gl.clear(gl.COLOR_BUFFER_BIT);

    // no rotation
    gl.uniform1f(theta_loc, 0.0);

    gl.vertexAttribPointer(colour_loc, 4, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(colour_loc);
    let num_line_vertices = indices.length;
    
    // B2: MODIFY CODE HERE
    gl.drawElements(gl.TRIANGLE_FAN, num_line_vertices, gl.UNSIGNED_SHORT, 0);

    // check if screen capture requested
    capture_canvas_check();

   // ask browser to call render() again, after 1/60 second
   window.setTimeout(render, 1000/60);
}

