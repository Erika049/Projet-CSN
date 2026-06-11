package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@AllArgsConstructor
public class LogDto {
    private Long          idLog;
    private String        nomPersonnel;
    private UUID          idPatient;
    private String        actionEffectuee;
    private String        adresseIp;
    private LocalDateTime horodatage;
}