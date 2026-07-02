package com.sideru.backend.client;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
public class CatalogoClient {

    private final RestClient.Builder restClientBuilder;

    public CatalogoProducto getProducto(String sku) {
        return restClientBuilder.build()
                .get()
                .uri("http://catalogo-service:8082/api/internal/productos/{sku}", sku)
                .retrieve()
                .body(CatalogoProducto.class);
    }

    public List<CatalogoProducto> getProductosBatch(List<String> skus) {
        CatalogoProducto[] result = restClientBuilder.build()
                .post()
                .uri("http://catalogo-service:8082/api/internal/productos/batch")
                .body(skus)
                .retrieve()
                .body(CatalogoProducto[].class);
        return result != null ? Arrays.asList(result) : List.of();
    }
}
