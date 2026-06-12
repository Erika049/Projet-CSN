package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class HopitalDto {
    private Long   idHopital;
    private String nom;
    private String adresse;
    private String codeUnique;
    private int    nbPersonnel;
}