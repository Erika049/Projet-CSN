package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@AllArgsConstructor
public class PassageEnAttenteDto {
    private UUID          idPassage;
    private UUID          idPatient;
    private String        nomPatient;
    private String        prenomPatient;
    private String        motifVisite;
    private String        heure;
    private String        hopital;
    private int           age;
    private String        groupeSanguin;
    private LocalDateTime dateAdmission;
}