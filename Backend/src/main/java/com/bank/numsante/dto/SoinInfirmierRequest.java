package com.bank.numsante.dto;

import lombok.Data;

@Data
public class SoinInfirmierRequest {
    private String typeSoin;    // ex: Pansement, Massage, Aspiration, Surveillance
    private String description; // ex: Plaie post-opératoire au genou gauche
}
