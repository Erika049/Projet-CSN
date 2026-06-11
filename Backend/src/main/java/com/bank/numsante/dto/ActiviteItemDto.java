package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ActiviteItemDto {
    private String  idPassage;     // null pour NOUVEAU_PATIENT
    private String  nomPatient;
    private String  prenomPatient;
    private String  motifVisite;
    private String  date;
    private String  heure;
    private String  statut;
    private boolean urgence;
    private String  type;          // SCAN | URGENCE | NOUVEAU_PATIENT
}
