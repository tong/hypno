package hypno.android;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;

class DayDream {

    static var view : View;
    static var isFullscreen = false;

    static function handleClick(e) {
        //view.direction = !view.direction;
    }

    static function handleMouseMove(e) {

        view.parameters.mouseX = e.pageX;
        view.parameters.mouseY = e.pageY;

        //view.numRings = e.pageY;
        view.speed = (window.innerWidth/2 - e.pageX) / 10;
    }

    static function handleMouseWheel(e) {
        //view.speed += e.wheelDelta / 100;
        //view.numRings += Std.int(e.wheelDelta / 50);
    }

    static function handleTouchMove(e) {
        var touch = e.targetTouches[0];
        view.parameters.mouseX = touch.pageX;
        view.parameters.mouseY = touch.pageY;
        view.speed = (window.innerWidth/2 - touch.pageX) / 10;
        //view.numRings = touch.pageY;
        //view.speed = (window.innerWidth/2 - touch.pageX) / 10;
    }

    static function handleWindowResize(e) {
        view.resize( window.innerWidth, window.innerHeight );
    }

    static function handleShaderError(e) {
        console.error( e );
    }

    static function update( time : Float ) {
        window.requestAnimationFrame( update );
        //view.parameters.mouseX = mouse.x;
        //view.parameters.mouseY = mouse.y;
        view.render( time );
    }

    static function handleDoubleClickBody(e) {
        toggleFullscreen();
    }

    static function toggleFullscreen() {
        if( isFullscreen ) {
            untyped document.webkitExitFullscreen();
            isFullscreen = false;
        } else {
            untyped document.body.webkitRequestFullscreen();
            isFullscreen = true;
        }
    }

    static function main() {

        var canvas = document.createCanvasElement();
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        document.body.appendChild( canvas );

        //var numRings = Std.int( ((canvas.width > canvas.height) ? canvas.width : canvas.height) / 10/2 );
        //var numCirclesStr = Std.string( numCircles );
        //if( numCirclesStr.indexOf('.') == -1 ) numCirclesStr += '.0';

        var numRings = 10;

        var quality = 1/window.devicePixelRatio;

        //om.util.CanvasUtil.scaleToScreenDensity( canvas );
        //trace(window.devicePixelRatio);

        view = new View( canvas, 1/window.devicePixelRatio );
        view.onError = handleShaderError;
        view.resize( window.innerWidth, window.innerHeight );
        try view.compile( Shader.getSource(true) ) catch(e:Dynamic) {
            trace(e);
            try view.compile( Shader.getSource(false) ) catch(e:Dynamic) {
                trace(e);
                return;
            }
        }

        view.numRings = 5;
        view.speed = 1;

        window.addEventListener( 'resize', handleWindowResize, false );
        window.addEventListener( 'mousemove', handleMouseMove, false );
        window.addEventListener( 'mousewheel', handleMouseWheel, false );
        document.body.addEventListener( 'dblclick', handleDoubleClickBody, false );
        //window.addEventListener( 'click', handleClick, false );
        canvas.addEventListener( 'mousemove', handleMouseMove, false );
        canvas.addEventListener( 'touchmove', handleTouchMove, false );

        window.requestAnimationFrame( update );
    }
}
