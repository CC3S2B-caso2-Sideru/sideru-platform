package com.sideru.backend.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

public record PedidoResponse(
    Integer id,
    Integer cotizacionId,
    OffsetDateTime fechaPedido,
    String estado,
    String motivoRechazo,
    BigDecimal total,
    String cliente,
    List<PedidoDetalleResponse> detalles
) {}
