package com.bank.numsante.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreerPersonnelRequest {

    @NotBlank
    private String nom;

    @NotBlank
    private String prenom;

    @NotBlank
    private String role;

    @NotBlank
    private String identifiantPro;

    @NotBlank
    private String motDePasse;

    @NotNull
    private Long idHopital;
}