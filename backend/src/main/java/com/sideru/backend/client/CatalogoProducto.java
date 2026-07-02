package com.sideru.backend.client;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * DTO local que representa la respuesta del microservicio Catálogo.
 * No se comparte código entre servicios — cada uno define su propio DTO.
 */
public record CatalogoProducto(
    Integer id,
    String sku,
    String nombre,
    BigDecimal precio,
    Integer stockMinimo
) {}
