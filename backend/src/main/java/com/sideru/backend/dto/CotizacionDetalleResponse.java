package com.sideru.backend.dto;

import java.math.BigDecimal;

public record CotizacionDetalleResponse(
    Integer id,
    String sku,
    String productoNombre,
    Integer cantidad,
    BigDecimal precioUnitario,
    BigDecimal descuento,
    BigDecimal subtotal
) {}
