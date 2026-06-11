package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.List;

@Data
@AllArgsConstructor
public class DashboardAccueilDto {
    private String agentPrenom;
    private String agentNom;
    private String nomHopital;
    private int    totalAdmissions;
    private int    enAttente;
    private int    urgences;
    private List<DashboardAdmissionDto> admissions;
}
