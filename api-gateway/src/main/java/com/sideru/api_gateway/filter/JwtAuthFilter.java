package com.sideru.api_gateway.filter;

import com.sideru.api_gateway.config.JwtProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import javax.crypto.SecretKey;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtAuthFilter implements GlobalFilter, Ordered {

    private final JwtProperties jwtProperties;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();

        if (isPublicPath(path)) {
            return chain.filter(exchange);
        }

        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return unauthorized(exchange, "Token no proporcionado");
        }

        String token = authHeader.substring(7);
        try {
            Claims claims = extractClaims(token);

            ServerHttpRequest mutatedRequest = exchange.getRequest().mutate()
                    .header("X-Cliente-Id", claimToString(claims.get("clienteId")))
                    .header("X-Cliente-Nombre", claimToString(claims.get("clienteNombre")))
                    .header("X-Username", claims.getSubject())
                    .header("X-Rol", claimToString(claims.get("rol")))
                    .header("X-Tipo", claimToString(claims.get("tipo")))
                    .header("X-Authorities", authoritiesToString(claims.get("authorities")))
                    .build();

            return chain.filter(exchange.mutate().request(mutatedRequest).build());
        } catch (Exception e) {
            return unauthorized(exchange, "Token inválido: " + e.getMessage());
        }
    }

    @Override
    public int getOrder() {
        return -100;
    }

    private boolean isPublicPath(String path) {
        List<String> exactPublicPaths = List.of(
                "/auth/login", "/auth/register",
                "/productos", "/categorias",
                "/api/auth/login", "/api/auth/register",
                "/api/productos", "/api/categorias"
        );
        if (exactPublicPaths.contains(path)) {
            return true;
        }

        List<String> publicPathPrefixes = List.of(
                "/swagger", "/v3/api-docs", "/docs"
        );
        return publicPathPrefixes.stream().anyMatch(path::startsWith);
    }

    private Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private SecretKey getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(jwtProperties.getSecretKey());
        return Keys.hmacShaKeyFor(keyBytes);
    }

    private String claimToString(Object value) {
        if (value == null) return "";
        return value.toString();
    }

    @SuppressWarnings("unchecked")
    private String authoritiesToString(Object authorities) {
        if (authorities instanceof List<?> list) {
            return String.join(",", list.stream().map(Object::toString).toList());
        }
        return "";
    }

    private Mono<Void> unauthorized(ServerWebExchange exchange, String message) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.UNAUTHORIZED);
        response.getHeaders().add("Content-Type", "application/json");
        String body = "{\"error\":\"" + message + "\",\"status\":401}";
        return response.writeWith(Mono.just(response.bufferFactory().wrap(body.getBytes())));
    }
}
