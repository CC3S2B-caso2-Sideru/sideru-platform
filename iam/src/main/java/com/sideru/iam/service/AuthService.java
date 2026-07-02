package com.sideru.iam.service;

import com.sideru.iam.dto.*;
import com.sideru.iam.entity.Cliente;
import com.sideru.iam.entity.TipoUsuario;
import com.sideru.iam.entity.Usuario;
import com.sideru.iam.repository.ClienteRepository;
import com.sideru.iam.repository.RolRepository;
import com.sideru.iam.repository.UsuarioRepository;
import com.sideru.iam.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final ClienteRepository clienteRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public TokenResponse register(RegisterRequest request) {
        if (usuarioRepository.findByUsername(request.username()).isPresent()) {
            throw new RuntimeException("El username ya está en uso");
        }
        if (usuarioRepository.findByEmail(request.email()).isPresent()) {
            throw new RuntimeException("El email ya está registrado");
        }

        var rol = rolRepository.findByNombre("cliente")
                .orElseThrow(() -> new RuntimeException("Rol cliente no encontrado"));

        var usuario = Usuario.builder()
                .username(request.username())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .tipo(TipoUsuario.CLIENTE)
                .rol(rol)
                .build();
        usuario = usuarioRepository.save(usuario);

        Cliente cliente = null;
        if (request.cliente() != null) {
            var c = request.cliente();
            cliente = Cliente.builder()
                    .usuario(usuario)
                    .dni(c.dni())
                    .ruc(c.ruc())
                    .razonSocial(c.razonSocial())
                    .nombre(c.nombre())
                    .apellido(c.apellido())
                    .telefono(c.telefono())
                    .direccion(c.direccion())
                    .build();
            cliente = clienteRepository.save(cliente);
        }

        return buildToken(usuario, cliente);
    }

    public TokenResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );

        var usuario = usuarioRepository.findByUsername(request.username()).orElseThrow();
        var cliente = clienteRepository.findByUsuario(usuario).orElse(null);

        return buildToken(usuario, cliente);
    }

    private TokenResponse buildToken(Usuario usuario, Cliente cliente) {
        String token = jwtService.generateToken(usuario, cliente);
        String clienteNombre = null;
        if (cliente != null) {
            clienteNombre = cliente.getRazonSocial() != null
                    ? cliente.getRazonSocial()
                    : cliente.getNombre() + " "
                    + (cliente.getApellido() != null ? cliente.getApellido() : "");
            clienteNombre = clienteNombre.trim();
        }

        return new TokenResponse(
                token,
                usuario.getUsername(),
                usuario.getRol().getNombre(),
                usuario.getTipo().name(),
                cliente != null ? cliente.getId() : null,
                clienteNombre
        );
    }
}
