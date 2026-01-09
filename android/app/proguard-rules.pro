# OkHttp & Okio
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# UCrop
-keep class com.yalantis.ucrop.** { *; }

# Firebase & Google Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter Firebase plugins
-keep class io.flutter.plugins.firebase.** { *; }

# Flutter App & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }

# Preserve generic signatures & annotations
-keepattributes Signature
-keepattributes *Annotation*