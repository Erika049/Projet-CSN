package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.List;

@Data
@AllArgsConstructor
public class InfirmierDashboardDto {
    private String infirmierPrenom;
    private String infirmierNom;
    private String nomHopital;
    private int    totalAConstanter;
    private int    urgences;
    private int    faits;
    private List<PassageInfirmierDto> passages;
}
