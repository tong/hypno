package hypno.view;

import js.html.CanvasElement;
import js.html.webgl.Program;

class FragmentShaderView extends om.webgl.FragmentShaderView {

    public var numRings = 100;
    public var speed = 1.0;

    public function new( canvas : CanvasElement, quality = 1.0, preserveDrawingBuffer = true ) {
        super( canvas, quality );
    }

    override function cacheUniformLocations( program : Program ) {
        cacheUniformLocation( program, 'numRings' );
        cacheUniformLocation( program, 'speed' );
    }

    override function setUniformsValues() {
        gl.uniform1f( untyped currentProgram.uniformsCache.numRings, numRings );
        gl.uniform1f( untyped currentProgram.uniformsCache.speed, speed );
    }

}
