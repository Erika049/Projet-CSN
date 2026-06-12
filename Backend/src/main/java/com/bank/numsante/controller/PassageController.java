package com.bank.numsante.controller;

import com.bank.numsante.dto.ConstantesVitalesRequest;
import com.bank.numsante.dto.ConsultationRequest;
import com.bank.numsante.service.PassageService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/passages")
@RequiredArgsConstructor
public class PassageController {

    private final PassageService passageService;

    @Operation(summary = "Mettre à jour les constantes vitales d’un passage")
    @PutMapping("/{idPassage}/constantes")
    public ResponseEntity<Map<String, String>> updateConstantes(@PathVariable UUID idPassage,
                                                                @Valid @RequestBody ConstantesVitalesRequest request,
                                                                Authentication authentication) {
        passageService.updateConstantes(idPassage, request, authentication.getName());
        return ResponseEntity.ok(Map.of("message", "Constantes vitales mises à jour avec succès"));
    }

    @Operation(summary = "Ajouter diagnostic / prescription et éventuellement clôturer le passage")
    @PutMapping("/{idPassage}/consultation")
    public ResponseEntity<Map<String, String>> ajouterConsultation(@PathVariable UUID idPassage,
                                                                   @Valid @RequestBody ConsultationRequest request,
                                                                   Authentication authentication) {
        passageService.ajouterConsultation(idPassage, request, authentication.getName());
        return ResponseEntity.ok(Map.of("message", "Dossier de consultation enregistré et archivé"));
    }

    @Operation(summary = "Enregistrer un soin infirmier")
    @PostMapping("/{idPassage}/soins")
    public ResponseEntity<Map<String, String>> logSoin(@PathVariable UUID idPassage,
                                                       @RequestBody Map<String, String> body,
                                                       Authentication authentication) {
        String desc = body.getOrDefault("typeSoin", "") + " - " + body.getOrDefault("description", "");
        passageService.logSoin(idPassage, desc, authentication.getName());
        return ResponseEntity.ok(Map.of("message", "Soin enregistré"));
    }

    @Operation(summary = "Enregistrer une injection")
    @PostMapping("/{idPassage}/injections")
    public ResponseEntity<Map<String, String>> logInjection(@PathVariable UUID idPassage,
                                                            @RequestBody Map<String, String> body,
                                                            Authentication authentication) {
        String desc = body.getOrDefault("medicament", "") + " " + body.getOrDefault("dose", "") + " via " + body.getOrDefault("voie", "");
        passageService.logInjection(idPassage, desc, authentication.getName());
        return ResponseEntity.ok(Map.of("message", "Injection enregistrée"));
    }
}