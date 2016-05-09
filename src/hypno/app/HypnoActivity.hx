package hypno.app;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import haxe.Resource;
import haxe.Template;
import hypno.view.FragmentShaderView;

class HypnoActivity extends om.app.Activity {

	var shader : Int;
    var view : FragmentShaderView;
	//var menu : Settings

    var animationFrameId : Int;
	var lastTouchX : Int;
    var lastTouchY : Int;

	//public function new( id : Int ) {}

	override function onCreate() {

		super.onCreate();

		var width = window.innerWidth;
		var height = window.innerHeight;

		var canvas = document.createCanvasElement();
        canvas.width = width;
        canvas.height = height;
        element.append( canvas );

		var src = om.res.Embed.shader( 'hypno-0' );
		//trace(src);
		view = new FragmentShaderView( canvas, 1 );
        view.onError = function(e){
            console.error(e);
            //replace( new ErrorActivity(e) );
        };
		try {
			view.compile( src );
		} catch(e:Dynamic) {
			trace(e);
		}

		/*
		var pixelRatio = window.devicePixelRatio;
		//view.resize( width, height );
		if( pixelRatio > 1 ) {
			var oldWidth = canvas.width;
			var oldHeight = canvas.height;
			canvas.width = Std.int( oldWidth * pixelRatio );
			canvas.height = Std.int( oldHeight * pixelRatio );
			canvas.style.width = oldWidth + 'px';
			canvas.style.height = oldHeight + 'px';
			//canvas.getContext2d().scale( pixelRatio, pixelRatio );
			//canvas.getContext2d().scale( pixelRatio, pixelRatio );
		}
		*/

		//view.resize( width, height );
		//view.gl.scale( pixelRatio, pixelRatio );

		/*
		var menu = document.createDivElement();
		menu.id = 'settings-menu';
		menu.textContent = 'HYPNO SETTINGS';
		element.append( menu );
		*/
	}

	override function onStart() {

        super.onStart();

		lastTouchX = lastTouchY = 0;

		animationFrameId = window.requestAnimationFrame( update );

		window.addEventListener( 'resize', handleWindowResize, false );

		view.canvas.addEventListener( 'mousedown', handleMouseDown, false );
        view.canvas.addEventListener( 'mousemove', handleMouseMove, false );
        view.canvas.addEventListener( 'touchstart', handleTouchStart, false );
        view.canvas.addEventListener( 'touchmove', handleTouchMove, false );
	}

	override function onStop() {

        super.onStop();

        if( animationFrameId != null ) {
			window.cancelAnimationFrame( animationFrameId );
			animationFrameId = null;
		}

		window.removeEventListener( 'resize', handleWindowResize );

		view.canvas.removeEventListener( 'mousedown', handleMouseDown );
        view.canvas.removeEventListener( 'mousemove', handleMouseMove );
        view.canvas.removeEventListener( 'touchstart', handleTouchStart );
        view.canvas.removeEventListener( 'touchmove', handleTouchMove );
	}

	function update( time : Float ) {
        animationFrameId = window.requestAnimationFrame( update );
        view.render( time );
    }

	function handleMouseDown(e) {
    }

	function handleMouseMove(e) {
		userInput( e.pageX, e.pageY );
	}

	function handleTouchStart(e) {
        var touch = e.targetTouches[0];
		//trace(touch.pageX, touch.pageY);
        userInput( touch.pageX, touch.pageY );
    }

    function handleTouchMove(e) {

        var touch = e.targetTouches[0];
        userInput( touch.pageX, touch.pageY );

        view.numRings = touch.pageY;
    }

    function userInput( x : Int, y : Int ) {

        if( x == lastTouchX && y == lastTouchY )
            return;

        view.speed = - (window.innerWidth/2 - x) / 10;
        view.numRings = Std.int(y);

        lastTouchX = x;
        lastTouchY = y;
    }

	function handleWindowResize(e) {
        view.resize( window.innerWidth, window.innerHeight );
    }

}
