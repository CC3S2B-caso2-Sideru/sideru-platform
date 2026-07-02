package com.sideru.backend.filter;

public record RequestContext(
    Integer clienteId,
    String clienteNombre,
    String username,
    String rol,
    String tipo,
    String authorities
) {}
