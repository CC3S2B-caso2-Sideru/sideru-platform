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
public class CategoriaService {

    private final CategoriaRepository categoriaRepository;

    @Transactional(readOnly = true)
    public List<CategoriaResponse> findAll() {
        return categoriaRepository.findAll().stream()
                .map(c -> new CategoriaResponse(c.getId(), c.getNombre()))
                .toList();
    }
}
