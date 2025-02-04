import 'package:harmonymusic/native_bindings/andrid_utils.dart';
import 'package:jni/jni.dart';

class EqualizerService {
  static bool openEqualizer(int sessionId) {
    JObject activity = JObject.fromReference(Jni.getCurrentActivity());
    JObject context = JObject.fromReference(Jni.getCachedApplicationContext());
    final success = Equalizer().openEqualizer(sessionId, context, activity);
    activity.release();
    context.release();
    return success;
  }

  static void initAudioEffect(int sessionId) {
    JObject context = JObject.fromReference(Jni.getCachedApplicationContext());
    Equalizer().initAudioEffect(sessionId, context);
    context.release();
  }

  static void endAudioEffect(int sessionId) {
    JObject context = JObject.fromReference(Jni.getCachedApplicationContext());
    Equalizer().endAudioEffect(sessionId, context);
    context.release();
  }
}
