package disktree.net.hypno;

import android.service.dreams.DreamService;
import android.view.View;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;

public class Dream extends DreamService {

    static final boolean DEBUG = true;
    static final String TAG = "hypno";

    private WebView webview;

    @Override
    public void onDreamingStarted() {
        super.onDreamingStarted();
        log( "======= onDreamingStarted =======");
    }

    @Override
    public void onDreamingStopped() {
        super.onDreamingStopped();
        log( "======= onDreamingStopped =======");
    }

    @Override
    public void onAttachedToWindow() {

        super.onAttachedToWindow();

        log( "======= onAttachedToWindow =======");

        setFullscreen(true);
        setInteractive(true);

        setContentView(R.layout.daydream);

        getWindow().getDecorView().setSystemUiVisibility( View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY );

        //WindowManager.LayoutParams layout = getWindow().getAttributes();
        //layout.screenBrightness = 0.1;
        //getWindow().setAttributes( layout );

        webview = (WebView) findViewById(R.id.webview);
        webview.setBackgroundColor(0x00000000);
        webview.clearCache(true);

        WebSettings settings = webview.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setAllowContentAccess(true);
        settings.setAllowFileAccess(true);
        settings.setAllowFileAccessFromFileURLs(true);
        settings.setDomStorageEnabled( true );

        webview.loadUrl("file:///android_asset/dream.html");
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        log( "======= onDetachedFromWindow =======");
    }

    private static final void log( String msg ) {
        if( DEBUG ){
            android.util.Log.d( TAG, msg );
        }
    }
}