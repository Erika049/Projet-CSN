package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDate;
import java.util.UUID;

@Data
@AllArgsConstructor
public class PatientProfilDto {
    private UUID idPatient;
    private String nom;
    private String prenom;
    private LocalDate dateNaissance;
    private Character genre;
    private String groupeSanguin;
    private String telephone;
    private String email;
    private String adresse;
    private String urgenceNom;
    private String urgenceTelephone;

    // Carte numérique
    private String qrCodeToken;
    private String carteStatut;
    private LocalDate carteExpiration;
}