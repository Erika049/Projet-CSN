package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class PersonnelProfilDto {
    private Long   idPersonnel;
    private String nom;
    private String prenom;
    private String role;
    private String identifiantPro;
    private Long   idHopital;
    private String nomHopital;
    private String adresseHopital;
}
