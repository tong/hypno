package hypno;

import js.Browser.document;
import js.Browser.window;
import hypno.app.HypnoticActivity;

#if android
import samba.android.SystemUi;
#end

//@:build(hypno.macro.BuildApp.build())
//@:keep
//@:build(hypno.macro.BuildHypnoApp.build())
class App extends samba.App {

    public static inline var NUM_HYPNOTICS = 5;

    public static var index(default,null) = 0;

    @:access(om.app.Activity)
    public static function next( currentActitvity : HypnoticActivity ) {
        if( ++index == NUM_HYPNOTICS ) index = 0;
        currentActitvity.replace( new HypnoticActivity( index ) );
    }

    @:access(om.app.Activity)
    public static function prev( currentActitvity : HypnoticActivity ) {
        if( --index == -1 ) index = NUM_HYPNOTICS;
        currentActitvity.replace( new HypnoticActivity( index ) );
    }

    override function init() {

        #if web
        // read url params for animation index
        #end

        new HypnoticActivity( index ).boot();
        //new hypno.app.AboutActivity().boot();

        /*
        //window.addEventListener();
        trace("DISKTREE.NET");

        #if android

        //samba.android.Toast.show( 'Samba!! '+Samba.VERSION );
        samba.android.Log.d( 'Samba!! '+Samba.VERSION );
        samba.android.Log.i( 'Samba!! '+Samba.VERSION );
        samba.android.Log.w( 'Samba!! '+Samba.VERSION );
        samba.android.Log.e( 'Samba!! '+Samba.VERSION );

        samba.android.Toast.show("DISKTREE.net");

        SystemUi.setFlag( SystemUi.HIDE_NAVIGATION | SystemUi.FULLSCREEN );

        #end
        */
    }

    static function main() {
        document.onreadystatechange = function(){
            if( document.readyState == 'complete' )
                samba.App.boot( hypno.App );
        }
    }
}
