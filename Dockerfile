# syntax=docker/dockerfile:1

# ---------- Build stage ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -B -q dependency:go-offline
COPY src ./src
# Tests are executed by the CI build-test job; skip them here to avoid duplicate work
RUN --mount=type=cache,target=/root/.m2 mvn -B -q package -DskipTests \
 && cp target/devsecops-app-*.jar /src/app.jar

# ---------- Runtime stage ----------
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
RUN apt-get update && apt-get -y upgrade --no-install-recommends && rm -rf /var/lib/apt/lists/* \
 && groupadd --system app && useradd --system --gid app --uid 10001 --no-create-home app
COPY --from=build --chown=app:app /src/app.jar app.jar
USER 10001
EXPOSE 8083
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget -qO- http://localhost:8083/actuator/health | grep -q '"status":"UP"' || exit 1
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/app.jar"]
