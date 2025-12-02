// ECS610U -- Miles Hansard 2021
'use strict';
var mesh, canvas, gl;
const vs_file = './lighting-vert.glsl';
const fs_file = './lighting-frag.glsl';

// illuminant properties
// B2 -- MODIFY
var light = {
    position: [10.0, 5.0, 10.0, 1.0],
    ambient:  [1.0, 1.0, 1.0, 1.0],
    diffuse:  [1.0, 1.0, 1.0, 1.0],
    specular: [1.0, 1.0, 1.0, 1.0],
};

// material properties
// B1 -- MODIFY
var material = {
    // gold
    ambient:  [0.24725, 0.19950, 0.07450, 1.0],
    diffuse:  [0.75164, 0.60648, 0.22648, 1.0],
    specular: [0.628281, 0.555802, 0.366065, 1.0],
    shininess: 51.2
};

// A2 -- CHANGE THIS
var num_models = 1;

// modelview parameters
var transform = [];

// viewing parameters
let vert_fov_deg = 20.0;
let near = 7.0;
let far = 12.0;
let aspect = 1;
var theta = 0.0;

// buffers and attributes
var projection, modelview, animate = false;

// uniform locations
var vertex_loc, normal_loc, projection_loc, modelview_loc;


async function init(meshes)
{
    // choose mesh from incoming list
    mesh = meshes.example;
    console.log('loaded mesh:');
    console.log(mesh);

    // set button to save the image
    capture_canvas_setup('gl-canvas', 'capture-button', 'capture.png');

    canvas = document.getElementById("gl-canvas");

    // boolean flag for mouse-click enabling/disabling of object motion 
    canvas.onclick = function() { animate = !animate; }

    gl = canvas.getContext('webgl', { alpha:false });

    // load the shader source code into JS strings
    const vs_src = await fetch(vs_file).then(out => out.text());
    const fs_src = await fetch(fs_file).then(out => out.text());
    // make the shaders and link them together as a program
    let vs = webgl_make_shader(gl, vs_src, gl.VERTEX_SHADER);
    let fs = webgl_make_shader(gl, fs_src, gl.FRAGMENT_SHADER);
    let program = webgl_make_program(gl, vs, fs);
    gl.useProgram(program);

    vertex_loc = gl.getAttribLocation(program, 'vertex');
    gl.enableVertexAttribArray(vertex_loc);

    normal_loc = gl.getAttribLocation(program, 'normal');
    gl.enableVertexAttribArray(normal_loc);

    // gl buffers will be created automatically by shared/webgl-obj-loader.js
    //for (let i = 0; i < mesh.vertices.length; i += 3) {
    //mesh.vertices[i    ] += 0.05 * random(-1, 1);  // x
    //mesh.vertices[i + 1] += 0.05 * random(-1, 1);  // y
    //mesh.vertices[i + 2] += 0.05 * random(-1, 1);  // z
    //} 
    for (let i = 0; i < mesh.vertexNormals.length; i += 3) {
    mesh.vertexNormals[i]     += 0.15 * random(-1, 1);  // nx
    mesh.vertexNormals[i + 1] += 0.15 * random(-1, 1);  // ny
    mesh.vertexNormals[i + 2] += 0.15 * random(-1, 1);  // nz
    }
    OBJ.initMeshBuffers(gl, mesh);

    // setup vertex attributes
    gl.bindBuffer(gl.ARRAY_BUFFER, mesh.vertexBuffer);
    gl.vertexAttribPointer(vertex_loc, mesh.vertexBuffer.itemSize, gl.FLOAT, false, 0, 0);

    // setup normal attributes
    gl.bindBuffer(gl.ARRAY_BUFFER, mesh.normalBuffer);
    gl.vertexAttribPointer(normal_loc, mesh.normalBuffer.itemSize, gl.FLOAT, false, 0, 0);

    // setup face indices
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.indexBuffer);

    // --- set light and material properties in shader

    // note that the GLSL/JS objects have the same property names as in the JS
    // hence the JS property names can be used to find the uniform locations
    for(let property in light) {
        gl.uniform4fv(gl.getUniformLocation(program,'light.'+property), 
                      light[property]);
    }
    for(let property in material) {
        if(property != 'shininess')
            gl.uniform4fv(gl.getUniformLocation(program, 'material.'+property), 
                          material[property]);
    }
    gl.uniform1f(gl.getUniformLocation(program,'material.shininess'), material.shininess);
    gl.uniform1f(gl.getUniformLocation(program,'near'), near);
    gl.uniform1f(gl.getUniformLocation(program,'far'), far);

    // --- get uniform locations ---

    modelview_loc = gl.getUniformLocation(program, 'modelview');
    projection_loc = gl.getUniformLocation(program, 'projection');

    // --- rendering setup ---

    gl.viewport(0, 0, canvas.width, aspect*canvas.height);
    gl.clearColor(1.0, 1.0, 1.0, 1.0);
    gl.lineWidth(1.0);
    gl.enable(gl.DEPTH_TEST);
    gl.depthFunc(gl.LEQUAL);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

    // projection matrix from shared/graphics.js
    projection = mat_perspective(vert_fov_deg, aspect, near, far);

    // random modelview parameters
    for(let k = 0; k < num_models; k++) {
        // empty struct
        transform[k] = {};
        // set random size, location, and rotation axis for each model
        transform[k].scale = vec_scale(random(1,10), [1,1,1]);
        transform[k].location = [random(-2,2), random(-2,2), -(far+near)/2 + random(-2,2)];
        transform[k].axis = [random(-1,1), random(-1,1), random(-1,1)];
    }


    render();
}


async function render() 
{
    // clear buffers and send projection matrix to shaders
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.uniformMatrix4fv(projection_loc, false, mat_float_flat_transpose(projection));

    // transformation and rendering 

    theta += 0.01 * animate;

    for(let k = 0; k < num_models; k++){

        // A1, A2 -- MODIFY HERE 

        let z = (far + near)/2;

        // Bouncing up and down
        let bounceHeight = 0.5 * Math.sin(theta * 3.0);
        let bouncingPosition = [0, bounceHeight, -z];

        // Spin on multiple axes
        let spinY = mat_rotation(theta, [0, 1, 0]);           
        let spinX = mat_rotation(theta * 0.5, [1, 0, 0]);    
        
        let combinedRotation = mat_prod(spinY, spinX);

        // Wobbling scale (breathing effect)
        let scaleAmount = 1.0 + 0.2 * Math.sin(theta * 2.0);
        let wobbleScale = mat_scaling([scaleAmount, scaleAmount, scaleAmount]);

        // Motion around center
        let orbitRadius = 2.0;
        let orbitX = orbitRadius * Math.cos(theta * 0.5);
        let orbitZ = orbitRadius * Math.sin(theta * 0.5);
        let orbitPosition = [orbitX, bounceHeight, -z + orbitZ];

        // Translate to the orbiting + bouncing position
        let translation = mat_translation(orbitPosition);

        let fullTransform = mat_prod(translation, mat_prod(mat_hom(combinedRotation), wobbleScale));

        modelview = fullTransform;

        gl.uniformMatrix4fv(modelview_loc, false, mat_float_flat_transpose(modelview));
        gl.drawElements(gl.TRIANGLES, mesh.indexBuffer.numItems, gl.UNSIGNED_SHORT, 0);
    }

    // check if screen capture requested
    capture_canvas_check();
    
    // ask browser to call render() again, after 1/60 second
    window.setTimeout(render, 1000/60);
}

window.onload = async function()
{
    // load the mesh and trigger init()
    // B1 -- MODIFY
    OBJ.downloadMeshes({
        'example': '../shared/models/suzanne.obj'
    }, init);
}
