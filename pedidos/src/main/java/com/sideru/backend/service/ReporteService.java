package com.sideru.backend.service;

import com.sideru.backend.dto.*;
import com.sideru.backend.repository.CotizacionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ReporteService {

    private final CotizacionRepository cotizacionRepository;

    @Transactional(readOnly = true)
    public List<ReporteEstado> cotizacionesPorEstado() {
        return cotizacionRepository.countByEstadoRaw().stream()
                .map(row -> new ReporteEstado((String) row[0], ((Number) row[1]).longValue()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ReporteMensual> cotizacionesPorMes(int meses) {
        return cotizacionRepository.countByMonthRaw(meses).stream()
                .map(row -> new ReporteMensual((String) row[0], ((Number) row[1]).longValue()))
                .toList();
    }

    @Transactional(readOnly = true)
    public ReporteIngresoRealVsPotencialResponse ingresoRealVsPotencial(int meses) {
        var raw = cotizacionRepository.findIngresoRealVsPotencialRaw(meses);
        var porMes = new ArrayList<ReporteIngresoRealVsPotencialResponse.IngresoMensual>();

        for (var row : raw) {
            porMes.add(new ReporteIngresoRealVsPotencialResponse.IngresoMensual(
                    (String) row[0], (BigDecimal) row[1], (BigDecimal) row[2]));
        }

        return new ReporteIngresoRealVsPotencialResponse(
                porMes,
                cotizacionRepository.sumTotalAceptadas(meses),
                cotizacionRepository.sumTotalRechazadas(meses)
        );
    }

    @Transactional(readOnly = true)
    public List<ReporteProductoMasCotizado> productosMasCotizados(int top) {
        return cotizacionRepository.findProductosMasCotizadosRaw(top).stream()
                .map(row -> new ReporteProductoMasCotizado(
                        (String) row[0], (String) row[1], ((Number) row[2]).longValue()))
                .toList();
    }
}
