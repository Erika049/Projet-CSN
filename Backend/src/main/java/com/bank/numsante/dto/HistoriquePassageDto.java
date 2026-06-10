package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data
@AllArgsConstructor
public class HistoriquePassageDto {
    private UUID idPassage;
    private String hopital;
    private String service;
    private String medecin;
    private LocalDateTime dateAdmission;
    private String motif;
    private Map<String, Object> constantes;
    private String diagnostic;
    private String prescription;
    private String statut;
    private List<ExamenDto> examens;

    @Data
    @AllArgsConstructor
    public static class ExamenDto {
        private Long idExamen;
        private String type;
        private String resultats;
        private LocalDateTime dateResultat;
    }
}