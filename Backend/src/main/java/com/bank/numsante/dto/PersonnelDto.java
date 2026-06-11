package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class PersonnelDto {
    private Long    idPersonnel;
    private String  nom;
    private String  prenom;
    private String  role;
    private String  identifiantPro;
    private String  hopital;
    private Long    idHopital;
    private Boolean estActif;
}