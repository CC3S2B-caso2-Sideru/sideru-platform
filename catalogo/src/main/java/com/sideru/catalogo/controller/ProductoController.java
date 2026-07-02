package com.sideru.catalogo.controller;

import com.sideru.catalogo.dto.ProductoResponse;
import com.sideru.catalogo.service.ProductoService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/productos")
@RequiredArgsConstructor
public class ProductoController {

    private final ProductoService productoService;

    @GetMapping
    public Page<ProductoResponse> findByFilters(
            @RequestParam(required = false) Integer categoriaId,
            @RequestParam(name = "categoria", required = false) Integer legacyCategoriaId,
            @RequestParam(required = false) String search,
            @RequestParam(name = "page", required = false) Integer legacyPage,
            @RequestParam(name = "n", required = false) Integer legacyPageSize,
            @PageableDefault(size = 12) Pageable pageable
    ) {
        Integer resolvedCategoriaId = categoriaId != null ? categoriaId : legacyCategoriaId;
        Pageable resolvedPageable = resolvePageable(pageable, legacyPage, legacyPageSize);
        return productoService.findByFilters(resolvedCategoriaId, search, resolvedPageable);
    }

    private Pageable resolvePageable(Pageable pageable, Integer legacyPage, Integer legacyPageSize) {
        if (legacyPage == null && legacyPageSize == null) {
            return pageable;
        }

        int page = legacyPage != null ? Math.max(legacyPage - 1, 0) : pageable.getPageNumber();
        int size = legacyPageSize != null ? Math.max(legacyPageSize, 1) : pageable.getPageSize();
        return PageRequest.of(page, size, pageable.getSort());
    }

    @GetMapping("/stock-bajo")
    public List<Map<String, Object>> stockBajo() {
        return productoService.findStockBajo()
                .stream()
                .<Map<String, Object>>map(producto -> Map.of(
                        "sku", producto.sku(),
                        "nombre", producto.nombre(),
                        "stock", producto.stock(),
                        "stockMinimo", producto.stockMinimo() != null ? producto.stockMinimo() : 0
                ))
                .toList();
    }
}
