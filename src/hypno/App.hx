package hypno;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;

class App {

	static inline function handleContextMenu(e) {
		e.preventDefault();
	}

	static inline function handleDoubleClick(e) {
		om.app.Window.toggleFullscreen();
	}

    static function main() {

		window.onload = function() {

			document.body.innerHTML = '';

			#if debug
			haxe.Log.trace = _trace;
			#end

			window.addEventListener( 'contextmenu', handleContextMenu, false );
			document.body.addEventListener( 'dblclick', handleDoubleClick, false );

			new hypno.app.HypnoActivity().boot();
		}
    }

	#if debug

	static function _trace( v : Dynamic, ?info : haxe.PosInfos ) {
		var str = info.fileName+':'+info.lineNumber+': '+v;
		if( info.customParams != null && info.customParams.length > 0 ) {
			switch info.customParams[0] {
				case 'log': console.log( str );
				case 'debug': console.debug( str );
				case 'warn': console.warn( str );
				case 'info': console.info( str );
				case 'error': console.error( str );
				default: console.log( str );
			}
		} else {
			console.log( str );
		}
	}

	#end
}
