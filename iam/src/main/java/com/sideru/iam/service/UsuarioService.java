package com.sideru.iam.service;

import com.sideru.iam.dto.ClienteResponse;
import com.sideru.iam.dto.UsuarioResponse;
import com.sideru.iam.repository.ClienteRepository;
import com.sideru.iam.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final ClienteRepository clienteRepository;

    @Transactional(readOnly = true)
    public List<UsuarioResponse> listarUsuarios() {
        return usuarioRepository.findAll().stream()
                .map(u -> new UsuarioResponse(
                        u.getId(),
                        u.getUsername(),
                        u.getEmail(),
                        u.getTipo().name(),
                        u.getRol().getNombre(),
                        u.getRol().getPermisosCodigos()
                ))
                .toList();
    }

    @Transactional(readOnly = true)
    public ClienteResponse getClienteById(Integer id) {
        return clienteRepository.findById(id)
                .map(c -> new ClienteResponse(c.getId(), c.getRazonSocial(), c.getNombre(), c.getApellido()))
                .orElse(null);
    }

    @Transactional(readOnly = true)
    public ClienteResponse getClienteByUsuarioId(Integer usuarioId) {
        return clienteRepository.findByUsuarioId(usuarioId)
                .map(c -> new ClienteResponse(c.getId(), c.getRazonSocial(), c.getNombre(), c.getApellido()))
                .orElse(null);
    }
}
