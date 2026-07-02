package com.sideru.catalogo.service;

import com.sideru.catalogo.dto.*;
import com.sideru.catalogo.entity.Producto;
import com.sideru.catalogo.repository.CategoriaRepository;
import com.sideru.catalogo.repository.ProductoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductoService {

    private final ProductoRepository productoRepository;
    private final CategoriaRepository categoriaRepository;

    @Transactional(readOnly = true)
    public Page<ProductoResponse> findByFilters(Integer categoriaId, String search, Pageable pageable) {
        return productoRepository.findByFilters(categoriaId, normalizeSearch(search), pageable)
                .map(this::toResponse);
    }

    @Transactional(readOnly = true)
    public Page<ProductoAdminResponse> findAllAdmin(String search, Integer categoriaId, Boolean activo,
                                                      Pageable pageable) {
        return productoRepository.findAdminByFilters(normalizeSearch(search), categoriaId, activo, pageable)
                .map(this::toAdminResponse);
    }

    @Transactional(readOnly = true)
    public List<ProductoAdminResponse> findStockBajo() {
        return productoRepository.findStockBajo().stream().map(this::toAdminResponse).toList();
    }

    @Transactional(readOnly = true)
    public ProductoAdminResponse findBySkuAdmin(String sku) {
        return productoRepository.findBySku(sku).map(this::toAdminResponse)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado: " + sku));
    }

    @Transactional(readOnly = true)
    public ProductoInfo getProductoInfo(String sku) {
        return productoRepository.findBySku(sku)
                .map(p -> new ProductoInfo(p.getId(), p.getSku(), p.getNombre(), p.getPrecio(), p.getStockMinimo()))
                .orElseThrow(() -> new RuntimeException("Producto no encontrado: " + sku));
    }

    @Transactional(readOnly = true)
    public List<ProductoInfo> getProductosBatch(List<String> skus) {
        return productoRepository.findBySkus(skus).stream()
                .map(p -> new ProductoInfo(p.getId(), p.getSku(), p.getNombre(), p.getPrecio(), p.getStockMinimo()))
                .toList();
    }

    @Transactional
    public ProductoAdminResponse create(ProductoRequest request) {
        var categoria = categoriaRepository.findById(request.categoriaId())
                .orElseThrow(() -> new RuntimeException("Categoría no encontrada"));

        var producto = Producto.builder()
                .sku(request.sku())
                .nombre(request.nombre())
                .descripcion(request.descripcion())
                .imagen(request.imagen())
                .precio(request.precio())
                .stock(request.stock() != null ? request.stock() : 0)
                .stockMinimo(request.stockMinimo())
                .categoria(categoria)
                .build();

        return toAdminResponse(productoRepository.save(producto));
    }

    @Transactional
    public ProductoAdminResponse update(String sku, ProductoRequest request) {
        var producto = productoRepository.findBySku(sku)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado: " + sku));

        var categoria = categoriaRepository.findById(request.categoriaId())
                .orElseThrow(() -> new RuntimeException("Categoría no encontrada"));

        producto.setSku(request.sku());
        producto.setNombre(request.nombre());
        producto.setDescripcion(request.descripcion());
        producto.setImagen(request.imagen());
        producto.setPrecio(request.precio());
        producto.setStock(request.stock() != null ? request.stock() : producto.getStock());
        producto.setStockMinimo(request.stockMinimo());
        producto.setCategoria(categoria);

        return toAdminResponse(productoRepository.save(producto));
    }

    @Transactional
    public ProductoAdminResponse toggleActive(String sku) {
        var producto = productoRepository.findBySku(sku)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado: " + sku));
        producto.setActivo(!Boolean.TRUE.equals(producto.getActivo()));
        return toAdminResponse(productoRepository.save(producto));
    }

    @Transactional
    public ProductoAdminResponse adjustStock(String sku, int cantidad) {
        var producto = productoRepository.findBySku(sku)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado: " + sku));
        producto.setStock(producto.getStock() + cantidad);
        return toAdminResponse(productoRepository.save(producto));
    }

    private ProductoResponse toResponse(Producto p) {
        return new ProductoResponse(p.getSku(), p.getNombre(), p.getImagen(), p.getPrecio(), p.getStock());
    }

    private String normalizeSearch(String search) {
        return search == null ? "" : search.trim();
    }

    private ProductoAdminResponse toAdminResponse(Producto p) {
        return new ProductoAdminResponse(
                p.getId(), p.getSku(), p.getNombre(), p.getDescripcion(),
                p.getImagen(), p.getPrecio(), p.getStock(),
                p.getStockMinimo(), p.getActivo(),
                p.getCategoria() != null ? p.getCategoria().getNombre() : null
        );
    }
}
