FROM ubuntu:latest
LABEL authors="mmaya"

# ══════════════════════════════════════════════
# STAGE 1 : Build avec Gradle + Java 17
# ══════════════════════════════════════════════
FROM gradle:8.14-jdk17 AS build
WORKDIR /app

# Copier les fichiers de build en premier (cache optimisé)
COPY build.gradle settings.gradle ./
COPY gradle gradle/

# Télécharger les dépendances sans builder
RUN gradle dependencies --no-daemon || true

# Copier le code source
COPY src src/

# Builder le jar
RUN gradle bootJar --no-daemon

# ══════════════════════════════════════════════
# STAGE 2 : Image légère pour l'exécution
# ══════════════════════════════════════════════
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copier le jar depuis le build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Port exposé
EXPOSE 8080

# Lancement
ENTRYPOINT ["java", "-jar", "app.jar"]