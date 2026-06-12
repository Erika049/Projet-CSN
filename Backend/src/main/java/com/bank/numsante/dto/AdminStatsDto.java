package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AdminStatsDto {
    private long nbPatients;
    private long nbPersonnel;
    private long nbHopitaux;
    private long nbPassagesAujourdhui;
    private long nbExamensAujourdhui;
}