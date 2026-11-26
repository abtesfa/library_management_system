
package com.library.library_backend.Config;

import java.nio.file.Path;
import java.nio.file.Paths;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${library.upload-dir}")
    private String uploadDirectory;

    @Override
    public void addResourceHandlers(
            ResourceHandlerRegistry registry) {

        // Permanent library logo storage
        Path uploadPath = Paths.get(uploadDirectory)
                .toAbsolutePath()
                .normalize();

        String location = uploadPath.toUri().toString();

        registry.addResourceHandler(
                "/uploads/library-logo/**"
        ).addResourceLocations(location);

        // Preserve existing general upload handling
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:uploads/");
    }
}
