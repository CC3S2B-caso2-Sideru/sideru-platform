package com.sideru.iam.dto;

public record RegisterRequest(
    String username,
    String password,
    String email,
    ClienteCreate cliente
) {}
