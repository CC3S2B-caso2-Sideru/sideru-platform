package com.sideru.backend.controller;

import com.sideru.backend.dto.PagoSimuladoRequest;
import com.sideru.backend.dto.PedidoResponse;
import com.sideru.backend.service.PedidoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pedidos")
@RequiredArgsConstructor
public class PedidoController {

    private final PedidoService pedidoService;

    @PostMapping("/desde-cotizacion/{cotizacionId}")
    @ResponseStatus(HttpStatus.CREATED)
    public PedidoResponse crearDesdeCotizacion(@PathVariable Integer cotizacionId) {
        return pedidoService.crearDesdeCotizacion(cotizacionId);
    }

    @GetMapping("/mis-pedidos")
    public List<PedidoResponse> listarMisPedidos() {
        return pedidoService.listarMisPedidos();
    }

    @GetMapping("/admin/todos")
    public List<PedidoResponse> listarTodos() {
        return pedidoService.listarTodos();
    }

    @PatchMapping("/{id}/registrar-pago")
    public PedidoResponse registrarPagoSimulado(
            @PathVariable Integer id,
            @RequestBody(required = false) PagoSimuladoRequest request
    ) {
        var safe = request != null ? request : new PagoSimuladoRequest(null, null);
        return pedidoService.registrarPagoSimulado(id, safe);
    }
}
