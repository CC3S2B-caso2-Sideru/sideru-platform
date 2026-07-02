package com.sideru.catalogo.dto;

import java.math.BigDecimal;

public record ProductoRequest(
    String sku,
    String nombre,
    String descripcion,
    String imagen,
    BigDecimal precio,
    Integer stock,
    Integer stockMinimo,
    Integer categoriaId
) {}
