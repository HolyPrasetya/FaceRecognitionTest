plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.facerecognition"
    compileSdk = 35              // ✅ update ke SDK 35
    ndkVersion = "27.0.12077973" // ✅ update ke NDK 27

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // ✅ Application ID unik (ubah kalau mau publish ke Play Store)
        applicationId = "com.example.facerecognition"
        // ✅ minSdk aman untuk universal APK
        minSdk = 21
        // ✅ target sesuai compileSdk
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: add keystore signing config kalau mau publish ke Play Store
            // Sementara pakai debug signing biar `flutter run --release` bisa jalan
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
