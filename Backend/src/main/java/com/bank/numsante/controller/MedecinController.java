package com.bank.numsante.controller;

import com.bank.numsante.dto.ActiviteProDto;
import com.bank.numsante.dto.PassageDetailDto;
import com.bank.numsante.dto.PatientDuJourDto;
import com.bank.numsante.service.MedecinService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/medecin")
@RequiredArgsConstructor
public class MedecinController {

    private final MedecinService medecinService;

    @GetMapping("/patients-du-jour")
    @Operation(summary = "Liste des patients du jour")
    public ResponseEntity<List<PatientDuJourDto>> getPatientsDuJour(
            Authentication auth) {
        return ResponseEntity.ok(
                medecinService.getPatientsDuJour(auth.getName()));
    }

    @GetMapping("/stats-du-jour")
    @Operation(summary = "Statistiques du jour")
    public ResponseEntity<Map<String, Integer>> getStatsDuJour(
            Authentication auth) {
        return ResponseEntity.ok(
                medecinService.getStatsDuJour(auth.getName()));
    }

    @GetMapping("/passages/{idPassage}")
    @Operation(summary = "Détail d'un passage médical")
    public ResponseEntity<PassageDetailDto> getPassageDetail(
            @PathVariable UUID idPassage) {
        return ResponseEntity.ok(
                medecinService.getPassageDetail(idPassage));
    }

    @GetMapping("/activite")
    @Operation(summary = "Activité du médecin")
    public ResponseEntity<List<ActiviteProDto>> getActivite(
            @RequestParam(defaultValue = "0") int jours,
            Authentication auth) {
        return ResponseEntity.ok(
                medecinService.getActivite(auth.getName(), jours));
    }
}