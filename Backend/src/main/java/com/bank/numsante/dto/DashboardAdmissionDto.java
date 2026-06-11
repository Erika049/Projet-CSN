package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class DashboardAdmissionDto {
    private String  idPassage;
    private String  nomPatient;
    private String  prenomPatient;
    private String  motifVisite;
    private String  heure;        // "09:34"
    private String  statut;       // "en_cours" | "termine"
    private boolean isUrgence;
}
