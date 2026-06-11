package com.bank.numsante.controller;

import com.bank.numsante.dto.ConstantesVitalesRequest;
import com.bank.numsante.dto.ConsultationRequest;
import com.bank.numsante.dto.SoinInfirmierRequest;
import com.bank.numsante.dto.InjectionInfirmierRequest;
import com.bank.numsante.security.CustomUserDetails;
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

    @Operation(summary = "Récupérer les constantes vitales existantes d’un passage")
    @GetMapping("/{idPassage}/constantes")
    public ResponseEntity<Map<String, String>> getConstantes(@PathVariable UUID idPassage) {
        return ResponseEntity.ok(passageService.getConstantes(idPassage));
    }

    @Operation(summary = "Mettre à jour les constantes vitales d’un passage")
    @PutMapping("/{idPassage}/constantes")
    public ResponseEntity<Map<String, String>> updateConstantes(@PathVariable UUID idPassage,
                                                                @Valid @RequestBody ConstantesVitalesRequest request,
                                                                Authentication authentication) {
        Long idPersonnel = extractPersonnelId(authentication);
        passageService.updateConstantes(idPassage, request, idPersonnel);
        return ResponseEntity.ok(Map.of("message", "Constantes vitales mises à jour avec succès"));
    }

    @Operation(summary = "Ajouter diagnostic / prescription et éventuellement clôturer le passage")
    @PutMapping("/{idPassage}/consultation")
    public ResponseEntity<Map<String, String>> ajouterConsultation(@PathVariable UUID idPassage,
                                                                   @Valid @RequestBody ConsultationRequest request,
                                                                   Authentication authentication) {
        Long idPersonnel = extractPersonnelId(authentication);
        passageService.ajouterConsultation(idPassage, request, idPersonnel);
        return ResponseEntity.ok(Map.of("message", "Dossier de consultation enregistré et archivé"));
    }

    @Operation(summary = "Enregistrer un soin infirmier pour un passage")
    @PostMapping("/{idPassage}/soin")
    public ResponseEntity<Map<String, String>> enregistrerSoin(@PathVariable UUID idPassage,
                                                               @RequestBody SoinInfirmierRequest request,
                                                               Authentication authentication) {
        passageService.enregistrerSoin(idPassage, request, extractPersonnelId(authentication));
        return ResponseEntity.ok(Map.of("message", "Soin enregistré avec succès"));
    }

    @Operation(summary = "Enregistrer une injection pour un passage")
    @PostMapping("/{idPassage}/injection")
    public ResponseEntity<Map<String, String>> enregistrerInjection(@PathVariable UUID idPassage,
                                                                    @RequestBody InjectionInfirmierRequest request,
                                                                    Authentication authentication) {
        passageService.enregistrerInjection(idPassage, request, extractPersonnelId(authentication));
        return ResponseEntity.ok(Map.of("message", "Injection enregistrée avec succès"));
    }

    private Long extractPersonnelId(Authentication auth) {
        if (auth != null && auth.getPrincipal() instanceof CustomUserDetails cud) {
            return cud.getPersonnel().getIdPersonnel();
        }
        return null;
    }
}