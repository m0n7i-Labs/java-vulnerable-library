# Stage 1: Build with Maven using a maintained Java 8 image
FROM maven:3.8.6-eclipse-temurin-8 AS builder
WORKDIR /app

# Copy project files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Create a minimal runtime image using Eclipse Temurin
FROM eclipse-temurin:8-jre
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/vulnerable-app-1.0-SNAPSHOT.jar app.jar

# Run the application on startup
CMD ["java", "-jar", "app.jar"]
