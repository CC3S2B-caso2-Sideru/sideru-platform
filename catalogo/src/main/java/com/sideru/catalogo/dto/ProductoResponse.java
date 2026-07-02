package com.sideru.catalogo.dto;

import java.math.BigDecimal;

public record ProductoResponse(
    String sku,
    String nombre,
    String imagen,
    BigDecimal precio,
    Integer stock
) {}
