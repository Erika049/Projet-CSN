package com.bank.numsante.controller;

import com.bank.numsante.dto.OrdonnanceDto;
import com.bank.numsante.service.OrdonnanceService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/pharmacien")
@RequiredArgsConstructor
public class PharmacienController {

    private final OrdonnanceService ordonnanceService;

    @GetMapping("/ordonnances-actives")
    @Operation(summary = "Toutes les ordonnances actives (pour tableau de bord pharmacien)")
    public ResponseEntity<List<OrdonnanceDto>> getOrdonnancesActives() {
        return ResponseEntity.ok(ordonnanceService.getAllOrdonnancesActives());
    }

    @GetMapping("/historique")
    @Operation(summary = "Historique des délivrances/refus (pour écran activité pharmacien)")
    public ResponseEntity<List<OrdonnanceDto>> getHistorique() {
        return ResponseEntity.ok(ordonnanceService.getHistoriquePharmacien());
    }
}
