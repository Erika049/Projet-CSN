package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ActiviteInfirmierItemDto {
    private String  idPassage;
    private String  nomPatient;
    private String  prenomPatient;
    private String  motifVisite;
    private String  date;
    private String  heure;
    private boolean urgence;
    private String  type;        // CONSTANTES | CONSTANTES_URGENCE
    private String  actionLabel; // "Constantes prises" | "Constantes urgence"
    private String  resume;      // "Tension 120/80 · 37.2°"
}
