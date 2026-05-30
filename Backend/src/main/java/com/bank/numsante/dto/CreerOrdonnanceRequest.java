package com.bank.numsante.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Data
public class CreerOrdonnanceRequest {
    @NotNull
    private UUID idPassage;

    @NotBlank
    private String titre;

    @NotNull
    private LocalDate dateExpiration;

    @NotNull
    private List<MedicamentRequest> medicaments;

    @Data
    public static class MedicamentRequest {
        @NotBlank
        private String nom;
        @NotBlank
        private String posologie;
        private Integer comprimesTotaux;
    }
}