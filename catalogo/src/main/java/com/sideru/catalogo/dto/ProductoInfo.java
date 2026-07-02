package com.sideru.catalogo.dto;

import java.math.BigDecimal;

public record ProductoInfo(
    Integer id,
    String sku,
    String nombre,
    BigDecimal precio,
    Integer stockMinimo
) {}
