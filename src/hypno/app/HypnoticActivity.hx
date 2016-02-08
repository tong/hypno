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
    var lastMouseX : Int;
    var lastMouseY : Int;

    public function new( shaderId : Int ) {
        super();
        this.shaderId = shaderId;
    }

    override function onCreate() {

        super.onCreate();

        trace( 'hypno-$shaderId' );

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
        shaderView.canvas.addEventListener( 'mousemove', handleMouseMove, false );
        shaderView.canvas.addEventListener( 'mousedown', handleMouseDown, false );

        /*
        element.onclick = function(){
            //push( new AboutActivity() );
        }
        */
    }

    override function onStop() {
        super.onStop();
        window.cancelAnimationFrame( animationFrameId );
        shaderView.canvas.removeEventListener( 'mousemove', handleMouseMove );
    }

    function update( time : Float ) {
        animationFrameId = window.requestAnimationFrame( update );
        shaderView.render( time );
    }

    function handleWindowResize(e) {
        shaderView.resize( window.innerWidth, window.innerHeight );
    }

    function handleMouseMove(e) {

        var mouseX = e.clientX;
		var mouseY = e.clientY;
        if( lastMouseX == mouseX && lastMouseY == mouseY )
			return;
        lastMouseX = mouseX;
        lastMouseY = mouseY;

        shaderView.parameters.mouseX = mouseX/100;
        shaderView.parameters.mouseY = mouseY/100;
    }

    function handleMouseDown(e) {
        //App.next( this );
    }
}
