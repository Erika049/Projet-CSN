package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.UUID;

@Data
@AllArgsConstructor
public class PatientDuJourDto {
    private UUID idPassage;
    private UUID idPatient;
    private String nom;
    private String prenom;
    private String motifVisite;
    private String heure;
    private String statut;
    private String groupeSanguin;
    private int age;
}