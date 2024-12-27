buildscript {
    val kotlinVersion = "1.8.22" // Definir la versión de Kotlin correctamente
    val gradle_version = "8.1"   // Ajusta según la versión de Gradle que uses

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.7.3")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("com.google.gms:google-services:4.3.15") // Asegúrate de que esté aquí

    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File(rootDir, "../build") // Cambiar String a File
subprojects {
    project.buildDir = File(rootProject.buildDir, project.name) // Cambiar String a File
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
