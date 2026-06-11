package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@AllArgsConstructor
public class ActiviteProDto {
    private UUID idPassage;
    private String type;
    private String label;
    private String patient;
    private String detail;
    private String tone;
    private LocalDateTime date;
}