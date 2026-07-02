package com.sideru.backend.controller;

import com.sideru.backend.dto.*;
import com.sideru.backend.service.ReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reportes")
@RequiredArgsConstructor
public class ReporteController {

    private final ReporteService reporteService;

    @GetMapping("/cotizaciones-por-estado")
    public List<ReporteEstado> cotizacionesPorEstado() {
        return reporteService.cotizacionesPorEstado();
    }

    @GetMapping("/cotizaciones-por-mes")
    public List<ReporteMensual> cotizacionesPorMes(@RequestParam(defaultValue = "6") int meses) {
        return reporteService.cotizacionesPorMes(meses);
    }

    @GetMapping("/ingreso-real-vs-potencial")
    public ReporteIngresoRealVsPotencialResponse ingresoRealVsPotencial(
            @RequestParam(defaultValue = "6") int meses) {
        return reporteService.ingresoRealVsPotencial(meses);
    }

    @GetMapping("/productos-mas-cotizados")
    public List<ReporteProductoMasCotizado> productosMasCotizados(@RequestParam(defaultValue = "5") int top) {
        return reporteService.productosMasCotizados(top);
    }
}
