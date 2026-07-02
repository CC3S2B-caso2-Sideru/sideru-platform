package com.sideru.iam.dto;

import java.util.List;

public record UsuarioResponse(
    Integer id,
    String username,
    String email,
    String tipo,
    String rol,
    List<String> permisos
) {}
