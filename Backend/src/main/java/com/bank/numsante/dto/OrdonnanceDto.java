package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Data
@AllArgsConstructor
public class OrdonnanceDto {
    private UUID idOrdonnance;
    private String titre;
    private String medecin;
    private String specialite;
    private String hopital;
    private LocalDate dateDelivrance;
    private LocalDate dateExpiration;
    private String statut;
    private int joursRestants;
    private List<MedicamentDto> medicaments;

    @Data
    @AllArgsConstructor
    public static class MedicamentDto {
        private Long idMedicament;
        private String nom;
        private String posologie;
        private Integer comprimesRestants;
        private Integer comprimesTotaux;
    }
}