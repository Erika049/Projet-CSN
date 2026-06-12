package com.bank.numsante.controller;

import com.bank.numsante.dto.ExamenDuJourDto;
import com.bank.numsante.dto.ExamenRequest;
import com.bank.numsante.dto.PassageEnAttenteDto;
import com.bank.numsante.service.LaboratoireService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/laboratoire")
@RequiredArgsConstructor
public class LaboratoireController {

    private final LaboratoireService laboratoireService;

    @PostMapping("/ajouter-examen")
    @Operation(summary = "Publier des résultats d'examen")
    public ResponseEntity<Map<String, String>> ajouterExamen(
            @Valid @RequestBody ExamenRequest request,
            Authentication auth) {
        laboratoireService.ajouterExamen(
                request, auth.getName());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Map.of("message",
                        "Résultats publiés sur le carnet du patient"));
    }

    @GetMapping("/passages-en-attente")
    @Operation(summary = "Passages en attente d'examen")
    public ResponseEntity<List<PassageEnAttenteDto>> getPassagesEnAttente(
            Authentication auth) {
        return ResponseEntity.ok(
                laboratoireService.getPassagesEnAttente(
                        auth.getName()));
    }

    @GetMapping("/historique")
    @Operation(summary = "Historique des examens publiés")
    public ResponseEntity<List<ExamenDuJourDto>> getHistorique(
            Authentication auth) {
        return ResponseEntity.ok(
                laboratoireService.getHistoriqueExamens(
                        auth.getName()));
    }

    @GetMapping("/stats")
    @Operation(summary = "Statistiques du laborantin")
    public ResponseEntity<Map<String, Long>> getStats(
            Authentication auth) {
        return ResponseEntity.ok(
                laboratoireService.getStats(
                        auth.getName()));
    }
}