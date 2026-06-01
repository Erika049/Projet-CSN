package com.bank.numsante.dto;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;

@Data
public class EnregistrementPatientRequest {
    @NotBlank
    private String nom;

    @NotBlank
    private String prenom;

    @NotNull
    private LocalDate dateNaissance;

    @NotNull
    private Character genre;

    private String groupeSanguin;

    @NotBlank
    private String telephone;

    @NotBlank
    @Email
    private String email;

    private String adresse;

    @NotBlank
    @Size(min = 4)
    private String identifiant;

    @NotBlank
    @Size(min = 12)
    private String motDePasse;

    // Contact urgence
    private String urgenceNom;
    private String urgenceTelephone;
}