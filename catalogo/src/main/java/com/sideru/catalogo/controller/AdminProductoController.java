package com.sideru.catalogo.controller;

import com.sideru.catalogo.dto.*;
import com.sideru.catalogo.service.ProductoService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/productos")
@RequiredArgsConstructor
public class AdminProductoController {

    private final ProductoService productoService;

    @GetMapping
    public Page<ProductoAdminResponse> findAllAdmin(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Integer categoriaId,
            @RequestParam(required = false) Boolean activo,
            @PageableDefault(size = 12) Pageable pageable
    ) {
        return productoService.findAllAdmin(search, categoriaId, activo, pageable);
    }

    @GetMapping("/stock-bajo")
    public List<ProductoAdminResponse> findStockBajo() {
        return productoService.findStockBajo();
    }

    @GetMapping("/{sku}")
    public ProductoAdminResponse findBySku(@PathVariable String sku) {
        return productoService.findBySkuAdmin(sku);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProductoAdminResponse create(@RequestBody ProductoRequest request) {
        return productoService.create(request);
    }

    @PutMapping("/{sku}")
    public ProductoAdminResponse update(@PathVariable String sku, @RequestBody ProductoRequest request) {
        return productoService.update(sku, request);
    }

    @PatchMapping("/{sku}/activar")
    public ProductoAdminResponse toggleActive(@PathVariable String sku) {
        return productoService.toggleActive(sku);
    }

    @PatchMapping("/{sku}/stock")
    public ProductoAdminResponse adjustStock(@PathVariable String sku, @RequestBody StockAdjustmentRequest request) {
        return productoService.adjustStock(sku, request.cantidad());
    }
}
