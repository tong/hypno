package hypno;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.Float32Array;
import js.html.webgl.Buffer;
import js.html.webgl.GL;
import js.html.webgl.Program;
import js.html.webgl.Shader;
import js.html.webgl.RenderingContext;

typedef Surface = Dynamic;
/* {
    var centerX : Int;
    var centerY : Int;
    var width : Int;
    var height : Int;
    var isPanning : Bool;
    var isZooming : Bool;
};
*/

typedef Parameters = {
    //var startTime : Float;
    var time : Float;
    var mouseX : Float;
    var mouseY : Float;
    var screenWidth : Int;
    var screenHeight : Int;
    var lastX : Int;
    var lastY : Int;
};

//class FragmentShaderPreview<Params> {
class View {

    static var screenVertexShaderSource = '
attribute vec3 position;
void main() {
    gl_Position = vec4( position, 1.0 );
}';

    static var screenFragmentShaderSource = '
precision mediump float;
uniform vec2 resolution;
uniform sampler2D texture;
void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    gl_FragColor = texture2D( texture, uv );
}';

    static var defaultSurfaceVertexShaderSource = '
attribute vec3 position;
attribute vec2 surfacePosAttrib;
varying vec2 surfacePosition;
void main() {
    surfacePosition = surfacePosAttrib;
    gl_Position = vec4( position, 1.0 );
}';

    public dynamic function onError( info : String ) {}

    public var canvas(default,null) : CanvasElement;
    public var gl(default,null)  : RenderingContext;
    public var quality(default,null) : Float;
    public var parameters(default,null) : Parameters;

    public var numRings = 100;
    public var direction = true;
    public var speed = 10.0;

    var buffer : Buffer;
    var surface : Surface;
    var currentProgram : Program;
    var vertexPosition : Int;
    var screenProgram : Program;
    var screenVertexPosition : Int;
    var frontTarget : Dynamic;
    var backTarget : Dynamic;
    //var errorLines = new Array<String>();

    public function new( canvas : CanvasElement, quality = 1.0 ) {

        this.canvas = canvas;
        this.quality = quality;

        surface = { centerX:0, centerY:0, width:1, height:1, isPanning:false, isZooming:false, lastX:0, lastY:0 };
        parameters = { time:0, mouseX:0.5, mouseY:0.5, screenWidth:canvas.width, screenHeight:canvas.height, lastX:0, lastY:0 };

        gl = canvas.getContextWebGL( { preserveDrawingBuffer: true } );
        buffer = gl.createBuffer();
        gl.bindBuffer( GL.ARRAY_BUFFER, buffer );
        gl.bufferData( GL.ARRAY_BUFFER, new Float32Array( [ - 1.0, - 1.0, 1.0, - 1.0, - 1.0, 1.0, 1.0, - 1.0, 1.0, 1.0, - 1.0, 1.0 ] ), GL.STATIC_DRAW );
        surface.buffer = gl.createBuffer();

        if( gl != null ) {
			gl.viewport( 0, 0, canvas.width, canvas.height );
			createRenderTargets();
		}

        compileScreenProgram();
    }

    public function resize( width : Int, height : Int, ?quality : Float ) {

        if( quality != null ) this.quality = quality;

        canvas.width = Std.int( width / this.quality );
		canvas.height = Std.int( height / this.quality );
        canvas.style.width = width + 'px';
		canvas.style.height = height + 'px';

        parameters.screenWidth = canvas.width;
		parameters.screenHeight = canvas.height;

        computeSurfaceCorners();

        if( gl != null ) {
			gl.viewport( 0, 0, canvas.width, canvas.height );
			createRenderTargets();
		}
    }

    public function compile( fragmentShaderSource : String, ?surfaceVertexShaderSource : String ) {

        if( surfaceVertexShaderSource == null )
            surfaceVertexShaderSource = defaultSurfaceVertexShaderSource;

        var program = gl.createProgram();

        var vs = createShader( surfaceVertexShaderSource, GL.VERTEX_SHADER );
		var fs = createShader( fragmentShaderSource, GL.FRAGMENT_SHADER );

        if( vs == null || fs == null )
            return null;

        gl.attachShader( program, vs );
    	gl.attachShader( program, fs );
    	gl.deleteShader( vs );
    	gl.deleteShader( fs );
    	gl.linkProgram( program );

        if( gl.getProgramParameter( program, GL.LINK_STATUS ) == null ) {
            var error = gl.getProgramInfoLog( program );
            onError( error );
            //onError( 'VALIDATE_STATUS: ' + gl.getProgramParameter( program, GL.VALIDATE_STATUS ), 'ERROR: ' + gl.getError() );
            //console.error( error );
            //console.error( 'VALIDATE_STATUS: ' + gl.getProgramParameter( program, GL.VALIDATE_STATUS ), 'ERROR: ' + gl.getError() );
            return;
        }

        if( currentProgram != null )
            gl.deleteProgram( currentProgram );

        currentProgram = program;

        cacheUniformLocation( program, 'time' );
		cacheUniformLocation( program, 'mouse' );
		cacheUniformLocation( program, 'resolution' );
		cacheUniformLocation( program, 'backbuffer' );
		cacheUniformLocation( program, 'surfaceSize' );

		cacheUniformLocation( program, 'numRings' );
		cacheUniformLocation( program, 'direction' );
		cacheUniformLocation( program, 'speed' );


        gl.useProgram( currentProgram );

        surface.positionAttribute = gl.getAttribLocation( currentProgram, "surfacePosAttrib" );
        //TODO gl.enableVertexAttribArray( surface.positionAttribute );

        vertexPosition = gl.getAttribLocation( currentProgram, "position" );
		gl.enableVertexAttribArray( vertexPosition );
    }

    public function render( time : Float ) {

        if( currentProgram == null )
            return;

        parameters.time = time;

        // Set uniforms for custom shader
		gl.useProgram( currentProgram );
		gl.uniform1f( untyped currentProgram.uniformsCache.time, parameters.time / 1000 );
		gl.uniform2f( untyped currentProgram.uniformsCache.mouse, parameters.mouseX, parameters.mouseY );
		gl.uniform2f( untyped currentProgram.uniformsCache.resolution, parameters.screenWidth, parameters.screenHeight );
		gl.uniform1i( untyped currentProgram.uniformsCache.backbuffer, 0 );
		gl.uniform2f( untyped currentProgram.uniformsCache.surfaceSize, surface.width, surface.height );

		gl.uniform1f( untyped currentProgram.uniformsCache.numRings, numRings );
		gl.uniform1f( untyped currentProgram.uniformsCache.speed, speed );
		gl.uniform1i( untyped currentProgram.uniformsCache.direction, direction ? 0 : 1 );

        //addUniforms();
		gl.bindBuffer( GL.ARRAY_BUFFER, surface.buffer );
        //TODO
        //gl.vertexAttribPointer( surface.positionAttribute, 2, GL.FLOAT, false, 0, 0 );

		gl.bindBuffer( GL.ARRAY_BUFFER, buffer );
		gl.vertexAttribPointer( vertexPosition, 2, GL.FLOAT, false, 0, 0 );
		gl.activeTexture( GL.TEXTURE0 );
		gl.bindTexture( GL.TEXTURE_2D, backTarget.texture );

        // Render custom shader to front buffer
		gl.bindFramebuffer( GL.FRAMEBUFFER, frontTarget.framebuffer );
		gl.clear( GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT );
		gl.drawArrays( GL.TRIANGLES, 0, 6 );

        // Set uniforms for screen shader
		gl.useProgram( screenProgram );
		gl.uniform2f( untyped screenProgram.uniformsCache.resolution, parameters.screenWidth, parameters.screenHeight );
		gl.uniform1i( untyped screenProgram.uniformsCache.texture, 1 );
		gl.bindBuffer( GL.ARRAY_BUFFER, buffer );
		gl.vertexAttribPointer( screenVertexPosition, 2, GL.FLOAT, false, 0, 0 );

		gl.activeTexture( GL.TEXTURE1 );
		gl.bindTexture( GL.TEXTURE_2D, frontTarget.texture );

        // Render front buffer to screen
		gl.bindFramebuffer( GL.FRAMEBUFFER, null );
		gl.clear( GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT );
		gl.drawArrays( GL.TRIANGLES, 0, 6 );

        // Swap buffers
		var tmp = frontTarget;
		frontTarget = backTarget;
		backTarget = tmp;
    }

    function createShader( src : String, type : Int ) : Shader {

        var shader = gl.createShader( type );
        var line, lineNum, lineError, index = 0, indexEnd;

        /*
        while( errorLines.length > 0 ) {
			line = errorLines.pop();
			//code.setLineClass(line, null);
			//code.clearMarker(line);
		}
        */

        gl.shaderSource( shader, src );
		gl.compileShader( shader );

        if( !gl.getShaderParameter( shader, GL.COMPILE_STATUS ) ) {

            var error = gl.getShaderInfoLog( shader );
			// Remove trailing linefeed, for FireFox's benefit.
			while( (error.length > 1) && (error.charCodeAt(error.length - 1) < 32) ) {
				error = error.substring(0, error.length - 1);
			}

            onError( error );

			while( index >= 0 ) {
				index = error.indexOf( "ERROR: 0:", index );
				if( index < 0 )
                    break;
				index += 9;
				indexEnd = error.indexOf( ':', index );
				if( indexEnd > index ) {
					lineNum = Std.parseInt( error.substring( index, indexEnd ) );
					if( !Math.isNaN( lineNum ) && (lineNum > 0) ) {
						index = indexEnd + 1;
						indexEnd = error.indexOf("ERROR: 0:", index);
						//lineError = htmlEncode((indexEnd > index) ? error.substring(index, indexEnd) : error.substring(index));
						//line = code.setMarker(lineNum - 1, '<abbr title="' + lineError + '">' + lineNum + '</abbr>', "errorMarker");
						//code.setLineClass(line, "errorLine");
						//errorLines.push(line);
					}
				}
			}

			return null;
		}
		return shader;
    }

    function compileScreenProgram() {

        if( gl == null )
            return;

        var program = gl.createProgram();
		var vs = createShader( screenVertexShaderSource, GL.VERTEX_SHADER );
		var fs = createShader( screenFragmentShaderSource, GL.FRAGMENT_SHADER );
		gl.attachShader( program, vs );
	    gl.attachShader( program, fs );
		gl.deleteShader( vs );
		gl.deleteShader( fs );
		gl.linkProgram( program );
		if( !gl.getProgramParameter( program, GL.LINK_STATUS ) ) {
			onError( 'VALIDATE_STATUS: ' + gl.getProgramParameter( program, GL.VALIDATE_STATUS ) );
            onError( 'ERROR: ' + gl.getError() );
			return;
		}
		screenProgram = program;
		gl.useProgram( screenProgram );
		cacheUniformLocation( program, 'resolution' );
		cacheUniformLocation( program, 'texture' );
		screenVertexPosition = gl.getAttribLocation( screenProgram, "position" );
		gl.enableVertexAttribArray( screenVertexPosition );
    }

    function cacheUniformLocation( program : Program, label : String ) {
        if( untyped program.uniformsCache == null ) {
			untyped program.uniformsCache = {};
		}
		untyped program.uniformsCache[ label ] = gl.getUniformLocation( program, label );
    }

    function computeSurfaceCorners() {
		if( gl != null ) {
			surface.width = surface.height * parameters.screenWidth / parameters.screenHeight;
			var halfWidth = surface.width * 0.5, halfHeight = surface.height * 0.5;
			gl.bindBuffer( GL.ARRAY_BUFFER, surface.buffer );
			gl.bufferData( GL.ARRAY_BUFFER, new Float32Array( [
				surface.centerX - halfWidth, surface.centerY - halfHeight,
				surface.centerX + halfWidth, surface.centerY - halfHeight,
				surface.centerX - halfWidth, surface.centerY + halfHeight,
				surface.centerX + halfWidth, surface.centerY - halfHeight,
				surface.centerX + halfWidth, surface.centerY + halfHeight,
				surface.centerX - halfWidth, surface.centerY + halfHeight ]
            ), GL.STATIC_DRAW );
		}
	}

    function createTarget( width : Int, height : Int ) {

        var target = {
            framebuffer : gl.createFramebuffer(),
    		renderbuffer : gl.createRenderbuffer(),
    		texture : gl.createTexture()
        };
		//target.framebuffer = gl.createFramebuffer();
		//target.renderbuffer = gl.createRenderbuffer();
		//target.texture = gl.createTexture();

        // set up framebuffer
		gl.bindTexture( GL.TEXTURE_2D, target.texture );
		gl.texImage2D( GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, null );
		gl.texParameteri( GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE );
		gl.texParameteri( GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE );
		gl.texParameteri( GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST );
		gl.texParameteri( GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST );
		gl.bindFramebuffer( GL.FRAMEBUFFER, target.framebuffer );
		gl.framebufferTexture2D( GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, target.texture, 0 );

        // set up renderbuffer
		gl.bindRenderbuffer( GL.RENDERBUFFER, target.renderbuffer );
		gl.renderbufferStorage( GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height );
		gl.framebufferRenderbuffer( GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, target.renderbuffer );

        // clean up
		gl.bindTexture( GL.TEXTURE_2D, null );
		gl.bindRenderbuffer( GL.RENDERBUFFER, null );
		gl.bindFramebuffer( GL.FRAMEBUFFER, null);

		return target;
	}

    function createRenderTargets() {
		frontTarget = createTarget( parameters.screenWidth, parameters.screenHeight );
		backTarget = createTarget( parameters.screenWidth, parameters.screenHeight );
	}

    static inline function now() : Float return window.performance.now();

}
