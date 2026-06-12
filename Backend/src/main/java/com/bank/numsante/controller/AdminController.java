package com.bank.numsante.controller;

import com.bank.numsante.dto.*;
import com.bank.numsante.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    // ── Stats ─────────────────────────────────────
    @GetMapping("/stats")
    @Operation(summary = "Statistiques globales")
    public ResponseEntity<AdminStatsDto> getStats() {
        return ResponseEntity.ok(
                adminService.getStats());
    }

    // ── Personnel ─────────────────────────────────
    @GetMapping("/personnel")
    @Operation(summary = "Liste du personnel médical")
    public ResponseEntity<List<PersonnelDto>> getPersonnel() {
        return ResponseEntity.ok(
                adminService.getPersonnel());
    }

    @PostMapping("/personnel")
    @Operation(summary = "Créer un compte professionnel")
    public ResponseEntity<PersonnelDto> creerPersonnel(
            @Valid @RequestBody
            CreerPersonnelRequest request) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(adminService.creerPersonnel(
                        request));
    }

    @PatchMapping("/personnel/{id}/toggle-actif")
    @Operation(summary = "Activer / désactiver un compte")
    public ResponseEntity<PersonnelDto> toggleActif(
            @PathVariable Long id) {
        return ResponseEntity.ok(
                adminService.toggleActif(id));
    }

    // ── Hôpitaux ──────────────────────────────────
    @GetMapping("/hopitaux")
    @Operation(summary = "Liste des hôpitaux")
    public ResponseEntity<List<HopitalDto>> getHopitaux() {
        return ResponseEntity.ok(
                adminService.getHopitaux());
    }

    @PostMapping("/hopitaux")
    @Operation(summary = "Ajouter un hôpital")
    public ResponseEntity<HopitalDto> creerHopital(
            @Valid @RequestBody
            CreerHopitalRequest request) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(adminService.creerHopital(
                        request));
    }

    // ── Logs ──────────────────────────────────────
    @GetMapping("/logs")
    @Operation(summary = "Logs de traçabilité")
    public ResponseEntity<List<LogDto>> getLogs(
            @RequestParam(defaultValue = "50")
            int limit) {
        return ResponseEntity.ok(
                adminService.getLogs(limit));
    }
}