# Stage 1: Build with Maven
FROM maven:3.8.6-eclipse-temurin-8 AS builder
WORKDIR /app

# Copy the pom and source
COPY pom.xml .
COPY src ./src

# Build the application - this creates the fat JAR in target/
RUN mvn clean package -DskipTests

# Stage 2: Minimal Runtime
FROM eclipse-temurin:8-jre
WORKDIR /app

# Copy the Fat JAR from the builder stage
# The filename is 'vulnerable-app-fat.jar' because of the finalName in pom.xml
COPY --from=builder /app/target/vulnerable-app-fat.jar app.jar

# Run the app
CMD ["java", "-jar", "app.jar"]
