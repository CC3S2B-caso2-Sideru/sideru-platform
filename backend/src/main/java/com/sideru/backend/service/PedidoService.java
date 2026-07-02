package com.sideru.backend.service;

import com.sideru.backend.dto.*;
import com.sideru.backend.entity.*;
import com.sideru.backend.filter.RequestContextHolder;
import com.sideru.backend.repository.CotizacionRepository;
import com.sideru.backend.repository.PedidoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PedidoService {

    private final PedidoRepository pedidoRepository;
    private final CotizacionRepository cotizacionRepository;

    @Transactional
    public PedidoResponse crearDesdeCotizacion(Integer cotizacionId) {
        var cotizacion = cotizacionRepository.findById(cotizacionId)
                .orElseThrow(() -> new RuntimeException("Cotización no encontrada: " + cotizacionId));

        if (cotizacion.getEstado() != EstadoCotizacion.aceptada) {
            throw new IllegalStateException("Solo se puede generar pedido desde una cotización aceptada");
        }

        if (pedidoRepository.existsByCotizacionId(cotizacionId)) {
            throw new RuntimeException("Ya existe un pedido para esta cotización");
        }

        var pedido = Pedido.builder()
                .cotizacion(cotizacion)
                .clienteId(cotizacion.getClienteId())
                .estado(EstadoPedido.pendiente)
                .total(cotizacion.getTotal())
                .build();

        List<PedidoDetalle> detalles = new ArrayList<>();
        for (var dc : cotizacion.getDetalles()) {
            var det = PedidoDetalle.builder()
                    .pedido(pedido)
                    .productoId(dc.getProductoId())
                    .productoSku(dc.getProductoSku())
                    .productoNombre(dc.getProductoNombre())
                    .cantidad(dc.getCantidad())
                    .precioUnitario(dc.getPrecioUnitario())
                    .descuento(dc.getDescuento())
                    .subtotal(dc.getSubtotal())
                    .build();
            detalles.add(det);
        }
        pedido.setDetalles(detalles);

        return toResponse(pedidoRepository.save(pedido));
    }

    @Transactional(readOnly = true)
    public List<PedidoResponse> listarMisPedidos() {
        Integer clienteId = RequestContextHolder.get().clienteId();
        String nombre = RequestContextHolder.get().clienteNombre();
        return pedidoRepository.findAllByClienteIdOrderByFechaPedidoDesc(clienteId)
                .stream().map(p -> toResponse(p)).toList();
    }

    @Transactional(readOnly = true)
    public List<PedidoResponse> listarTodos() {
        return pedidoRepository.findAllByOrderByFechaPedidoDesc()
                .stream().map(p -> toResponse(p)).toList();
    }

    @Transactional
    public PedidoResponse registrarPagoSimulado(Integer pedidoId, PagoSimuladoRequest request) {
        Integer clienteId = RequestContextHolder.get().clienteId();
        var pedido = pedidoRepository.findById(pedidoId)
                .orElseThrow(() -> new RuntimeException("Pedido no encontrado: " + pedidoId));

        if (!pedido.getClienteId().equals(clienteId)) {
            throw new RuntimeException("No puedes pagar un pedido de otro cliente");
        }

        if (pedido.getEstado() != EstadoPedido.pendiente) {
            throw new IllegalStateException("Solo se pueden pagar pedidos pendientes");
        }

        pedido.setEstado(EstadoPedido.confirmado);
        return toResponse(pedidoRepository.save(pedido));
    }

    private PedidoResponse toResponse(Pedido pedido) {
        var detalles = pedido.getDetalles().stream()
                .map(d -> new PedidoDetalleResponse(
                        d.getId(), d.getProductoSku(), d.getProductoNombre(),
                        d.getCantidad(), d.getPrecioUnitario(), d.getDescuento(), d.getSubtotal()
                )).toList();

        return new PedidoResponse(
                pedido.getId(),
                pedido.getCotizacion().getId(),
                pedido.getFechaPedido(),
                pedido.getEstado().name(),
                pedido.getMotivoRechazo(),
                pedido.getTotal(),
                null, detalles
        );
    }
}
