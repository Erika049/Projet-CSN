package com.bank.numsante.dto;
import lombok.Data;

@Data
public class ConstantesVitalesRequest {
    private String tension;
    private String temperature;
    private String poids;
    private String freqCardiaque;
    private String spo2;
    private String freqRespi;
    private String noteInfirmiere;
}