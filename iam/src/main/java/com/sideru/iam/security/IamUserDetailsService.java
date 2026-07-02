package com.sideru.iam.security;

import com.sideru.iam.entity.Usuario;
import com.sideru.iam.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class IamUserDetailsService implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado: " + username));

        List<SimpleGrantedAuthority> authorities = usuario.getRol().getPermisosCodigos().stream()
                .map(SimpleGrantedAuthority::new)
                .toList();

        return new org.springframework.security.core.userdetails.User(
                usuario.getUsername(),
                usuario.getPasswordHash(),
                usuario.getActivo(),
                true, true, true,
                authorities
        );
    }
}
