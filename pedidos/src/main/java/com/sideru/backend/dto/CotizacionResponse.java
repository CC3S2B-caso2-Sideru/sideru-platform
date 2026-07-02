package com.sideru.backend.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

public record CotizacionResponse(
    Integer id,
    OffsetDateTime fechaEmision,
    LocalDate fechaExpiracion,
    String estado,
    String observaciones,
    BigDecimal subtotal,
    BigDecimal igv,
    BigDecimal total,
    String cliente,
    List<CotizacionDetalleResponse> detalles
) {}
