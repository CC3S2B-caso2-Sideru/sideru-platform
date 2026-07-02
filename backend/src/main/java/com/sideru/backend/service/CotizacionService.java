package com.sideru.backend.service;

import com.sideru.backend.client.CatalogoClient;
import com.sideru.backend.client.CatalogoProducto;
import com.sideru.backend.dto.*;
import com.sideru.backend.entity.*;
import com.sideru.backend.filter.RequestContext;
import com.sideru.backend.filter.RequestContextHolder;
import com.sideru.backend.repository.CotizacionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CotizacionService {

    private final CotizacionRepository cotizacionRepository;
    private final CatalogoClient catalogoClient;
    private final PedidoService pedidoService;

    @Transactional
    public CotizacionResponse crearCotizacion(CotizacionRequest request) {
        RequestContext ctx = RequestContextHolder.get();
        Integer clienteId = ctx.clienteId();
        if (clienteId == null) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Solo los usuarios cliente pueden crear cotizaciones");
        }

        List<String> skus = request.items().stream().map(CotizacionItemRequest::sku).toList();
        Map<String, CatalogoProducto> productos = catalogoClient.getProductosBatch(skus).stream()
                .collect(Collectors.toMap(CatalogoProducto::sku, p -> p));

        Cotizacion cotizacion = Cotizacion.builder()
                .clienteId(clienteId)
                .fechaExpiracion(LocalDate.now().plusDays(7))
                .observaciones(request.observaciones())
                .build();

        BigDecimal subtotalAcumulado = BigDecimal.ZERO;
        boolean excedeStockMinimo = false;
        List<CotizacionDetalle> detalles = new ArrayList<>();

        for (CotizacionItemRequest item : request.items()) {
            CatalogoProducto producto = productos.get(item.sku());
            if (producto == null) {
                throw new RuntimeException("Producto no encontrado: " + item.sku());
            }

            Integer minimo = producto.stockMinimo();
            if (minimo == null || item.cantidad() > minimo) {
                excedeStockMinimo = true;
            }

            BigDecimal precio = producto.precio();
            BigDecimal cantidad = BigDecimal.valueOf(item.cantidad());
            BigDecimal itemSubtotal = precio.multiply(cantidad);
            subtotalAcumulado = subtotalAcumulado.add(itemSubtotal);

            CotizacionDetalle detalle = CotizacionDetalle.builder()
                    .cotizacion(cotizacion)
                    .productoId(producto.id())
                    .productoSku(producto.sku())
                    .productoNombre(producto.nombre())
                    .cantidad(item.cantidad())
                    .precioUnitario(precio)
                    .subtotal(itemSubtotal)
                    .build();
            detalles.add(detalle);
        }

        BigDecimal subtotal = subtotalAcumulado;
        BigDecimal igv = subtotal.multiply(BigDecimal.valueOf(0.18)).setScale(2, RoundingMode.HALF_UP);
        BigDecimal total = subtotal.add(igv);

        cotizacion.setEstado(excedeStockMinimo ? EstadoCotizacion.enviada : EstadoCotizacion.aceptada);
        cotizacion.setSubtotal(subtotal);
        cotizacion.setIgv(igv);
        cotizacion.setTotal(total);
        cotizacion.setDetalles(detalles);

        Cotizacion guardada = cotizacionRepository.save(cotizacion);
        if (guardada.getEstado() == EstadoCotizacion.aceptada) {
            pedidoService.crearDesdeCotizacion(guardada.getId());
        }

        return toResponse(guardada, ctx.clienteNombre());
    }

    @Transactional(readOnly = true)
    public List<CotizacionResponse> listarMisCotizaciones() {
        Integer clienteId = RequestContextHolder.get().clienteId();
        String clienteNombre = RequestContextHolder.get().clienteNombre();

        return cotizacionRepository.findAllByClienteIdOrderByFechaEmisionDesc(clienteId)
                .stream().map(c -> toResponse(c, clienteNombre)).toList();
    }

    @Transactional(readOnly = true)
    public List<CotizacionResponse> listarTodas() {
        return cotizacionRepository.findAllByOrderByFechaEmisionDesc()
                .stream().map(c -> toResponse(c, null)).toList();
    }

    @Transactional
    public CotizacionResponse aceptarCotizacion(Integer id) {
        var c = cotizacionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cotización no encontrada: " + id));

        if (c.getEstado() != EstadoCotizacion.enviada) {
            throw new IllegalStateException("Solo se pueden aceptar cotizaciones en estado enviada");
        }

        c.setEstado(EstadoCotizacion.aceptada);
        var guardada = cotizacionRepository.save(c);
        pedidoService.crearDesdeCotizacion(guardada.getId());
        return toResponse(guardada, null);
    }

    @Transactional
    public CotizacionResponse rechazarCotizacion(Integer id) {
        var c = cotizacionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cotización no encontrada: " + id));

        if (c.getEstado() != EstadoCotizacion.enviada) {
            throw new IllegalStateException("Solo se pueden rechazar cotizaciones en estado enviada");
        }

        c.setEstado(EstadoCotizacion.rechazada);
        return toResponse(cotizacionRepository.save(c), null);
    }

    private CotizacionResponse toResponse(Cotizacion c, String clienteNombre) {
        var detalles = c.getDetalles().stream()
                .map(d -> new CotizacionDetalleResponse(
                        d.getId(),
                        d.getProductoSku(),
                        d.getProductoNombre(),
                        d.getCantidad(),
                        d.getPrecioUnitario(),
                        d.getDescuento(),
                        d.getSubtotal()
                )).toList();

        return new CotizacionResponse(
                c.getId(), c.getFechaEmision(), c.getFechaExpiracion(),
                c.getEstado().name(), c.getObservaciones(),
                c.getSubtotal(), c.getIgv(), c.getTotal(),
                clienteNombre, detalles
        );
    }
}
