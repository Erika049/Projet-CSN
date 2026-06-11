package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.List;

@Data
@AllArgsConstructor
public class ActiviteAgentDto {
    private int                  totalActions;
    private int                  scans;
    private int                  creations;
    private int                  urgences;
    private List<ActiviteItemDto> passages;
}
