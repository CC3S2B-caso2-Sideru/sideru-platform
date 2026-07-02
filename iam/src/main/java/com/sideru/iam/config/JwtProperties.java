package com.sideru.iam.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "security.jwt")
public class JwtProperties {
    private String secretKey;
    private long expirationMs = 86400000;
}
