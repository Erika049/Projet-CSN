package com.bank.numsante.controller;

import com.bank.numsante.dto.CreerOrdonnanceRequest;
import com.bank.numsante.dto.OrdonnanceDto;
import com.bank.numsante.service.OrdonnanceService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ordonnances")
@RequiredArgsConstructor
public class OrdonnanceController {

    private final OrdonnanceService ordonnanceService;

    @GetMapping("/patient/{idPatient}")
    @Operation(summary = "Toutes les ordonnances d'un patient")
    public ResponseEntity<List<OrdonnanceDto>> getOrdonnances(
            @PathVariable UUID idPatient) {
        return ResponseEntity.ok(
                ordonnanceService.getOrdonnances(idPatient));
    }

    @GetMapping("/patient/{idPatient}/actives")
    @Operation(summary = "Ordonnances actives d'un patient")
    public ResponseEntity<List<OrdonnanceDto>> getOrdonnancesActives(
            @PathVariable UUID idPatient) {
        return ResponseEntity.ok(
                ordonnanceService.getOrdonnancesActives(idPatient));
    }

    @GetMapping("/{idOrdonnance}")
    @Operation(summary = "Détail d'une ordonnance")
    public ResponseEntity<OrdonnanceDto> getOrdonnance(
            @PathVariable UUID idOrdonnance) {
        return ResponseEntity.ok(
                ordonnanceService.getOrdonnance(idOrdonnance));
    }

    @PostMapping
    @Operation(summary = "Créer une ordonnance (médecin)")
    public ResponseEntity<OrdonnanceDto> creerOrdonnance(
            @Valid @RequestBody CreerOrdonnanceRequest request,
            Authentication authentication) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ordonnanceService.creerOrdonnance(
                        request, authentication.getName()));
    }
}