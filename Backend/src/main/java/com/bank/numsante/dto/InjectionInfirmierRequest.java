package com.bank.numsante.dto;

import lombok.Data;

@Data
public class InjectionInfirmierRequest {
    private String medicament; // ex: Paracétamol, Amoxicilline
    private String dose;       // ex: 1g, 500mg
    private String voie;       // IV, IM, SC
}
