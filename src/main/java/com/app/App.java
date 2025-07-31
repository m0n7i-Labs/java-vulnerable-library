package com.example;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.core.SpringVersion;

public class App {
    private static final Logger logger = LogManager.getLogger(App.class);

    public static void main(String[] args) throws Exception {
        // Serialize a simple array to JSON using Jackson
        ObjectMapper mapper = new ObjectMapper();
        String json = mapper.writeValueAsString(new int[]{1, 2, 3});

        // Log the serialized JSON using Log4j
        logger.info("Serialized JSON: {}", json);

        // Print out the Spring Framework version
        System.out.println("Spring version: " + SpringVersion.getVersion());
    }
}
