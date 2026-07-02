package com.sideru.catalogo.controller;

import com.sideru.catalogo.dto.ProductoInfo;
import com.sideru.catalogo.service.ProductoService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/internal/productos")
@RequiredArgsConstructor
public class InternalProductoController {

    private final ProductoService productoService;

    @GetMapping("/{sku}")
    public ProductoInfo getBySku(@PathVariable String sku) {
        return productoService.getProductoInfo(sku);
    }

    @PostMapping("/batch")
    public List<ProductoInfo> getBySkus(@RequestBody List<String> skus) {
        return productoService.getProductosBatch(skus);
    }
}
