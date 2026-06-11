package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Data
@AllArgsConstructor
public class PassageDetailDto {
    private UUID idPassage;
    private String nomPatient;
    private String prenomPatient;
    private UUID idPatient;
    private String hopital;
    private String motifVisite;
    private LocalDateTime dateAdmission;
    private String statut;
    private Map<String, Object> constantesVitales;
    private String diagnostic;
    private String prescriptionOrdonnance;
}