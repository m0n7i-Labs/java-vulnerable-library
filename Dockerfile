#Test

# Stage 1: Build with Maven and include vulnerable dependencies
FROM maven:3.6.3-jdk-8 AS builder
WORKDIR /app

# Copy project files
COPY pom.xml .
COPY src ./src

# Build the application (vulnerable libraries will be pulled in)
RUN mvn clean package -DskipTests

# Stage 2: Create a minimal runtime image
FROM openjdk:8-jre
WORKDIR /app
COPY --from=builder /app/target/vulnerable-app-1.0-SNAPSHOT.jar app.jar

# Run the application on startup
CMD ["java", "-jar", "app.jar"]
