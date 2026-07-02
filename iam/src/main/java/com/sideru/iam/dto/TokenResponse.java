package com.sideru.iam.dto;

public record TokenResponse(
    String token,
    String username,
    String rol,
    String tipo,
    Integer clienteId,
    String clienteNombre
) {}
