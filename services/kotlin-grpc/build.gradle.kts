plugins {
    kotlin("jvm") version "2.1.20"
    id("com.google.protobuf") version "0.9.4"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("io.grpc:grpc-netty-shaded:1.68.1")
    implementation("io.grpc:grpc-protobuf:1.68.1")
    implementation("io.grpc:grpc-stub:1.68.1")
    implementation("com.google.protobuf:protobuf-java:3.25.5")
    implementation("javax.annotation:javax.annotation-api:1.3.2")
}

sourceSets {
    main {
        proto {
            srcDir("proto")
        }
    }
}

protobuf {
    protoc {
        artifact = "com.google.protobuf:protoc:3.25.5"
    }
}

application {
    mainClass.set("MainKt")
}