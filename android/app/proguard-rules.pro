# ========================
# 📸 ML Kit Text Recognition
# ========================

# Keep all ML Kit Text Recognition classes
-keep class com.google.mlkit.vision.text.** { *; }

# Keep all language-specific options
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# ========================
# 🧠 TensorFlow Lite GPU
# ========================

# Keep GPU Delegate classes
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.delegate.** { *; }

# Specifically keep GpuDelegateFactory internal options
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options$GpuBackend { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate$Options { *; }

# ========================
# ⚙️ ML Kit Commons
# ========================
-keep class com.google_mlkit_commons.** { *; }

# ========================
# 🧹 Suppress Warnings
# ========================
-dontwarn com.google_mlkit_commons.InputImageConverter
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn com.google.mlkit.vision.text.**
