package com.sideru.iam.security;

import com.sideru.iam.config.JwtProperties;
import com.sideru.iam.entity.Cliente;
import com.sideru.iam.entity.Usuario;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class JwtService {

    private final JwtProperties jwtProperties;

    public String generateToken(Usuario usuario, Cliente cliente) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("rol", usuario.getRol().getNombre());
        claims.put("tipo", usuario.getTipo().name());

        if (cliente != null) {
            claims.put("clienteId", cliente.getId());
            String nombre = cliente.getRazonSocial() != null
                    ? cliente.getRazonSocial()
                    : cliente.getNombre() + " "
                    + (cliente.getApellido() != null ? cliente.getApellido() : "");
            claims.put("clienteNombre", nombre.trim());
        }

        claims.put("authorities", usuario.getRol().getPermisosCodigos());

        return Jwts.builder()
                .claims(claims)
                .subject(usuario.getUsername())
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + jwtProperties.getExpirationMs()))
                .signWith(getSigningKey())
                .compact();
    }

    public boolean isTokenValid(String token) {
        try {
            extractClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public Claims extractClaims(String token) {
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
}
