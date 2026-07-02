package com.sideru.catalogo.repository;

import com.sideru.catalogo.entity.Producto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductoRepository extends JpaRepository<Producto, Integer> {

    Optional<Producto> findBySku(String sku);

    List<Producto> findAllByCategoriaId(Integer categoriaId);

    @Query("""
        SELECT p FROM Producto p
        WHERE p.activo = true
        AND (:categoriaId IS NULL OR p.categoria.id = :categoriaId)
        AND (LOWER(p.nombre) LIKE LOWER(CONCAT('%', :search, '%'))
             OR LOWER(p.sku) LIKE LOWER(CONCAT('%', :search, '%'))
             OR LOWER(p.categoria.nombre) LIKE LOWER(CONCAT('%', :search, '%')))
        ORDER BY p.updatedAt DESC
    """)
    Page<Producto> findByFilters(
            @Param("categoriaId") Integer categoriaId,
            @Param("search") String search,
            Pageable pageable
    );

    @Query("""
        SELECT p FROM Producto p
        WHERE (LOWER(p.nombre) LIKE LOWER(CONCAT('%', :search, '%'))
             OR LOWER(p.sku) LIKE LOWER(CONCAT('%', :search, '%')))
        AND (:categoriaId IS NULL OR p.categoria.id = :categoriaId)
        AND (:activo IS NULL OR p.activo = :activo)
        ORDER BY p.updatedAt DESC
    """)
    Page<Producto> findAdminByFilters(
            @Param("search") String search,
            @Param("categoriaId") Integer categoriaId,
            @Param("activo") Boolean activo,
            Pageable pageable
    );

    @Query("SELECT p FROM Producto p WHERE p.stock <= p.stockMinimo AND p.activo = true")
    List<Producto> findStockBajo();

    @Query("SELECT p FROM Producto p WHERE p.sku IN :skus")
    List<Producto> findBySkus(@Param("skus") List<String> skus);
}
