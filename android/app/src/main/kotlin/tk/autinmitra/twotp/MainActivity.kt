package tk.autinmitra.twotp

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.view.WindowManager.LayoutParams;

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        getWindow().addFlags(LayoutParams.FLAG_SECURE);
    }
}
