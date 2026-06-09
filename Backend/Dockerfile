FROM ubuntu:latest
LABEL authors="mmaya"
# ══════════════════════════════════════════════
# STAGE 1 : Build avec Gradle + Java 17
# ══════════════════════════════════════════════
FROM gradle:8.14-jdk17 AS build
WORKDIR /app
COPY build.gradle settings.gradle ./
COPY gradle gradle/
RUN gradle dependencies --no-daemon || true
COPY src src/
RUN gradle bootJar --no-daemon

# ══════════════════════════════════════════════
# STAGE 2 : Image légère pour l'exécution
# ══════════════════════════════════════════════
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
COPY docker-entrypoint.sh docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["./docker-entrypoint.sh"]