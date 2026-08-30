# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ffmpeg_kit_flutter_new - JNI bridge classes must not be renamed/stripped.
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-dontwarn com.arthenica.ffmpegkit.**

# video_player (ExoPlayer-based) reflection safety.
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**


# Play Core deferred components - not used in this app, safe to ignore.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
