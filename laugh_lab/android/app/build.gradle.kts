plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dustinshoemake.laugh_lab"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Make sure this NDK version is installed via Android Studio SDK Manager

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dustinshoemake.laugh_lab"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23 // Increase minSdk to 23 for firebase_auth_ktx compatibility
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Add this dependencies block
dependencies {
    // Use Kotlin syntax (parentheses and double quotes)
    implementation(platform("com.google.firebase:firebase-bom:33.1.1")) // Firebase BOM
    implementation("com.google.firebase:firebase-appcheck-playintegrity") // Firebase App Check

    // Add other Firebase dependencies using Kotlin syntax (-ktx recommended)
    implementation("com.google.firebase:firebase-auth-ktx") // Added for Firebase Auth
    implementation("com.google.firebase:firebase-firestore-ktx") // Added for Cloud Firestore
    // implementation("com.google.firebase:firebase-analytics-ktx")
    // ... add any others you need ...

    // Standard Kotlin dependency (often required)
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:${rootProject.extra["kotlin_version"]}")

    // Default Flutter dependencies might be needed if not added elsewhere
    // implementation("androidx.core:core-ktx:+")
    // implementation("androidx.appcompat:appcompat:+")
    // implementation("androidx.activity:activity-ktx:+") // Example
}
