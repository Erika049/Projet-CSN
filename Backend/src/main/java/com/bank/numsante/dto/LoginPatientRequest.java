package com.bank.numsante.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginPatientRequest {
    @NotBlank
    private String identifiant;
    @NotBlank
    private String motDePasse;
}