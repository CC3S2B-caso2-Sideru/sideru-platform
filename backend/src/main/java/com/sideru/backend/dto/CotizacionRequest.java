package com.sideru.backend.dto;

import java.util.List;

public record CotizacionRequest(
    String observaciones,
    List<CotizacionItemRequest> items
) {}
