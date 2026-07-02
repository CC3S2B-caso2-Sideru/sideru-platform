package com.sideru.iam.controller;

import com.sideru.iam.dto.ClienteResponse;
import com.sideru.iam.dto.UsuarioResponse;
import com.sideru.iam.service.UsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    @GetMapping("/usuarios")
    @PreAuthorize("hasAuthority('usuario.gestionar')")
    public List<UsuarioResponse> listarUsuarios() {
        return usuarioService.listarUsuarios();
    }

    @GetMapping("/internal/clientes/{id}")
    public ClienteResponse getClienteById(@PathVariable Integer id) {
        return usuarioService.getClienteById(id);
    }

    @GetMapping("/internal/clientes/por-usuario/{usuarioId}")
    public ClienteResponse getClienteByUsuarioId(@PathVariable Integer usuarioId) {
        return usuarioService.getClienteByUsuarioId(usuarioId);
    }
}
