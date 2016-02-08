package hypno.app;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import hypno.webgl.FragmentShaderView;
import haxe.Resource;
import haxe.Template;

class HypnoticActivity extends om.app.Activity {

    var shaderId : Int;
    var shaderView : FragmentShaderView;
    var animationFrameId : Int;
    //var lastMouseX : Int;
    //var lastMouseY : Int;
    var lastTouchX : Int;
    var lastTouchY : Int;

    public function new( shaderId : Int ) {
        super();
        this.shaderId = shaderId;
    }

    override function onCreate() {

        super.onCreate();

        trace( 'hypno-$shaderId' );

        lastTouchX = lastTouchY = 0;

        var canvas = document.createCanvasElement();
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        element.append( canvas );

        shaderView = new FragmentShaderView( canvas, 1 );
        shaderView.onError = function(e){
            console.error(e);
            //replace( new ErrorActivity(e) );
        };

        var ctx = {
            precision: 'highp'
        };
        var tpl = new Template( Resource.getString( 'hypno-'+shaderId ) );
        try {
            var shaderSource = tpl.execute( ctx );
            //trace(shaderSource);
            shaderView.compile( tpl.execute( ctx ) );
            } catch(e:Dynamic) {
                trace(e);
                //replace( new ErrorActivity( e ) );
            }
    }

    override function onStart() {

        super.onStart();

        animationFrameId = window.requestAnimationFrame( update );

        window.addEventListener( 'resize', handleWindowResize, false );
        shaderView.canvas.addEventListener( 'mousedown', handleMouseDown, false );
        shaderView.canvas.addEventListener( 'mousemove', handleMouseMove, false );
        shaderView.canvas.addEventListener( 'touchstart', handleTouchStart, false );
        shaderView.canvas.addEventListener( 'touchmove', handleTouchMove, false );
    }

    override function onStop() {

        super.onStop();

        window.cancelAnimationFrame( animationFrameId );

        window.removeEventListener( 'resize', handleWindowResize );
        shaderView.canvas.removeEventListener( 'mousedown', handleMouseDown );
        shaderView.canvas.removeEventListener( 'mousemove', handleMouseMove );
        shaderView.canvas.removeEventListener( 'touchstart', handleTouchStart );
        shaderView.canvas.removeEventListener( 'touchmove', handleTouchMove );
    }

    function update( time : Float ) {
        animationFrameId = window.requestAnimationFrame( update );
        shaderView.render( time );
    }

    function handleMouseDown(e) {
        //App.next( this );
    }

    function handleMouseMove(e) {
        /*
        var mouseX = e.clientX;
		var mouseY = e.clientY;
        if( lastMouseX == mouseX && lastMouseY == mouseY )
			return;
        lastMouseX = mouseX;
        lastMouseY = mouseY;

        shaderView.parameters.mouseX = mouseX;
        shaderView.parameters.mouseY = mouseY;
        */
    }

    function handleTouchStart(e) {
        var touch = e.targetTouches[0];
        handleTouchInput( touch.pageX, touch.pageY );
    }

    function handleTouchMove(e) {
        var touch = e.targetTouches[0];
        handleTouchInput( touch.pageX, touch.pageY );

        //shaderView.numRings = touch.pageY;
    }

    function handleTouchInput( x : Int, y : Int ) {
        if( x == lastTouchX && y == lastTouchY )
            return;
        shaderView.speed = - (window.innerWidth/2 - x) / 10;
        shaderView.numRings = y;
        lastTouchX = x;
        lastTouchY = y;
    }

    function handleWindowResize(e) {
        shaderView.resize( window.innerWidth, window.innerHeight );
    }
}
