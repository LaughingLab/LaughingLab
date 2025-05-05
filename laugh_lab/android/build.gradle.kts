buildscript {
    val kotlinVersion = "1.8.22" // Define the Kotlin version statically
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Use the defined variable
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    // Ensure the kotlin_version property is set for subprojects
    extra.set("kotlin_version", "1.8.22")

    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
