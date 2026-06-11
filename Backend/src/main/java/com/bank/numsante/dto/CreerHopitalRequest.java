package com.bank.numsante.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreerHopitalRequest {

    @NotBlank
    private String nom;

    @NotBlank
    private String adresse;

    @NotBlank
    private String codeUnique;
}