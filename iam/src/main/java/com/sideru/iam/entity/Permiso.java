package com.sideru.iam.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "permiso")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Permiso {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String codigo;

    private String modulo;
    private String accion;
    private String descripcion;

    @ManyToMany(mappedBy = "permisos")
    @Builder.Default
    private Set<Rol> roles = new HashSet<>();
}
