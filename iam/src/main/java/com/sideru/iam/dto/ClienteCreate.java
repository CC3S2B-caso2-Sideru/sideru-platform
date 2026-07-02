package com.sideru.iam.dto;

public record ClienteCreate(
    String dni,
    String ruc,
    String razonSocial,
    String nombre,
    String apellido,
    String telefono,
    String direccion
) {}
