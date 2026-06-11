package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.List;

@Data
@AllArgsConstructor
public class ActiviteInfirmierDto {
    private int totalActions;
    private int constantes;
    private int soins;
    private int injections;
    private int urgences;
    private List<ActiviteInfirmierItemDto> items;
}
