package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@AllArgsConstructor
public class ExamenDuJourDto {
    private Long          idExamen;
    private UUID          idPassage;
    private UUID          idPatient;
    private String        nomPatient;
    private String        prenomPatient;
    private String        typeExamen;
    private String        resultats;
    private LocalDateTime dateResultat;
    private String        hopital;
    private int           age;
    private String        groupeSanguin;
}