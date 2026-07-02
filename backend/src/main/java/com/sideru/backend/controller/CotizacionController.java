package com.sideru.backend.controller;

import com.sideru.backend.dto.CotizacionRequest;
import com.sideru.backend.dto.CotizacionResponse;
import com.sideru.backend.service.CotizacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cotizaciones")
@RequiredArgsConstructor
public class CotizacionController {

    private final CotizacionService cotizacionService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CotizacionResponse crear(@RequestBody CotizacionRequest request) {
        return cotizacionService.crearCotizacion(request);
    }

    @GetMapping("/mis-cotizaciones")
    public List<CotizacionResponse> listarMisCotizaciones() {
        return cotizacionService.listarMisCotizaciones();
    }

    @GetMapping("/admin/todas")
    public List<CotizacionResponse> listarTodas() {
        return cotizacionService.listarTodas();
    }

    @PatchMapping("/{id}/aceptar")
    public CotizacionResponse aceptar(@PathVariable Integer id) {
        return cotizacionService.aceptarCotizacion(id);
    }

    @PatchMapping("/{id}/rechazar")
    public CotizacionResponse rechazar(@PathVariable Integer id) {
        return cotizacionService.rechazarCotizacion(id);
    }
}
