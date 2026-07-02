package com.sideru.iam.repository;

import com.sideru.iam.entity.Cliente;
import com.sideru.iam.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ClienteRepository extends JpaRepository<Cliente, Integer> {
    Optional<Cliente> findByUsuario(Usuario usuario);
    Optional<Cliente> findByUsuarioId(Integer usuarioId);
}
