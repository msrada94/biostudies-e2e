import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "1.7.20"
    id("org.jlleitschuh.gradle.ktlint") version "11.0.0"
    id("io.gitlab.arturbosch.detekt") version "1.22.0"
    application
}

group = "org.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("io.cucumber:cucumber-java:7.8.1")
    testImplementation("io.cucumber:cucumber-junit-platform-engine:7.8.1")
    testImplementation("org.junit.platform:junit-platform-suite:1.9.1")

    testImplementation("org.springframework:spring-web:5.3.23")
    testImplementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.14.0")

    testImplementation("org.skyscreamer:jsonassert:1.5.1")
    testImplementation("org.assertj:assertj-core:3.23.1")
    implementation("com.jayway.jsonpath:json-path:2.7.0")

    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}

tasks.withType<KotlinCompile> {
    kotlinOptions.jvmTarget = "1.8"
}

application {
    mainClass.set("RunCucumberTestKt")
}
