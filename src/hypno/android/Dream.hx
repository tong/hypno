package hypno.android;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;

class Dream {

    static var view : View;

    static function handleShaderError(e) {
        console.error( e );
    }

    static function handleWindowResize(e) {
        view.resize( window.innerWidth, window.innerHeight );
    }

    static function handleMouseMove(e) {
        view.numRings = e.pageY;
        view.speed = (window.innerWidth/2 - e.pageX) / 10;
    }

    static function handleClick(e) {
        //view.direction = !view.direction;
    }

    static function handleTouchMove(e) {
        var touch = e.targetTouches[0];
        view.numRings = touch.pageY;
        view.speed = (window.innerWidth/2 - touch.pageX) / 10;
    }

    static function update( time : Float ) {
        window.requestAnimationFrame( update );
        view.render( time );
    }

    static function getFragmentShaderCode( high : Bool ) : String {
        return
'#ifdef GL_ES
precision '+(high?'high':'medium')+'p float;
#endif

uniform vec2 resolution;
uniform float time;

uniform float numRings;
uniform float speed;

float rings(vec2 pos) {
    return cos( length( pos ) * numRings - time * speed );
}

void main() {
    vec2 pos = (gl_FragCoord.xy * 2.0 - resolution) / resolution.y;
    gl_FragColor = vec4( rings( pos ) );
}';
    }

    static function main() {

        window.onload = function(_){

            var canvas = document.createCanvasElement();
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            document.body.appendChild( canvas );

            var numCircles = ((canvas.width > canvas.height) ? canvas.width : canvas.height) / 3;
            var numCirclesStr = Std.string( numCircles );
            if( numCirclesStr.indexOf('.') == -1 ) numCirclesStr += '.0';

            var quality = 1/window.devicePixelRatio;
            
            //om.util.CanvasUtil.scaleToScreenDensity( canvas );

            view = new View( canvas, 1/window.devicePixelRatio );
            view.onError = handleShaderError;
            view.resize( window.innerWidth, window.innerHeight );
            try view.compile( getFragmentShaderCode( true ) ) catch(e:Dynamic) {
                trace(e);
                try view.compile( getFragmentShaderCode( false ) ) catch(e:Dynamic) {
                    trace(e);
                    return;
                }
            }

            window.addEventListener( 'resize', handleWindowResize, false );
            window.addEventListener( 'mousemove', handleMouseMove, false );
            //window.addEventListener( 'click', handleClick, false );
            canvas.addEventListener( 'touchmove', handleTouchMove, false );

            window.requestAnimationFrame( update );
        }
    }
}
