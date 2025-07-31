# Build with Maven and include vulnerable dependencies
FROM maven:3.6.3-jdk-8 AS builder
WORKDIR /app

# Create pom.xml with known vulnerable versions
RUN cat << 'EOF' > pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>vulnerable-app</artifactId>
    <version>1.0-SNAPSHOT</version>
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
    </properties>
    <dependencies>
        <!-- Jackson-databind 2.9.8 (CVE-2018-7489, CVE-2018-14719) -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.9.8</version>
        </dependency>
        <!-- log4j-core 2.8.2 (CVE-2017-5638) -->
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-core</artifactId>
            <version>2.8.2</version>
        </dependency>
        <!-- Spring-core 4.3.0.RELEASE (CVE-2018-1271) -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
            <version>4.3.0.RELEASE</version>
        </dependency>
    </dependencies>
</project>
EOF

# Create a simple Java application that uses the vulnerable libraries
RUN mkdir -p src/main/java/com/example && cat << 'EOF' > src/main/java/com/example/App.java
package com.example;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.core.SpringVersion;

public class App {
    private static final Logger logger = LogManager.getLogger(App.class);
    public static void main(String[] args) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        String json = mapper.writeValueAsString(new int[]{1,2,3});
        logger.info("Serialized JSON: {}", json);
        System.out.println("Spring version: " + SpringVersion.getVersion());
    }
}
EOF

# Build the application (vulnerable libraries will be pulled in)
RUN mvn clean package -DskipTests

# Stage 2: Create a minimal runtime image
FROM openjdk:8-jre
WORKDIR /app
COPY --from=builder /app/target/vulnerable-app-1.0-SNAPSHOT.jar ./app.jar

# Run the application on startup
CMD ["java", "-jar", "app.jar"]
