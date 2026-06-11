package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class PassageInfirmierDto {
    private String  idPassage;
    private String  nomPatient;
    private String  prenomPatient;
    private String  motifVisite;
    private String  heure;
    private boolean urgence;
    private boolean constantesFaites;
}
