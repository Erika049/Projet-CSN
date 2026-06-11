package com.bank.numsante.controller;

import com.bank.numsante.dto.*;
import com.bank.numsante.entity.Patient;
import com.bank.numsante.exception.ResourceNotFoundException;
import com.bank.numsante.repository.PatientRepository;
import com.bank.numsante.service.PatientService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/patients")
@RequiredArgsConstructor
public class PatientController {

    private final PatientService patientService;
    private final PatientRepository patientRepository;

    @PostMapping("/enregistrer")
    @Operation(summary = "Enregistrer un nouveau patient (inscription publique ou par agent)")
    public ResponseEntity<Map<String, Object>> enregistrerPatient(
            @Valid @RequestBody EnregistrementPatientRequest request,
            Authentication authentication) {
        // Si un agent authentifié appelle cet endpoint, son identifiant est transmis
        String identifiantCreateur = (authentication != null && authentication.isAuthenticated())
                ? authentication.getName() : null;
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(patientService.enregistrerPatient(request, identifiantCreateur));
    }

    @GetMapping("/{idPatient}/profil")
    @Operation(summary = "Profil complet du patient")
    public ResponseEntity<PatientProfilDto> getProfil(
            @PathVariable UUID idPatient) {
        return ResponseEntity.ok(patientService.getProfil(idPatient));
    }

    @GetMapping("/{idPatient}/historique")
    @Operation(summary = "Historique médical d'un patient")
    public ResponseEntity<List<HistoriquePassageDto>> getHistorique(
            @PathVariable UUID idPatient) {
        return ResponseEntity.ok(patientService.getHistorique(idPatient));
    }

    @GetMapping("/{idPatient}/passage-en-cours")
    @Operation(summary = "Passage médical actif du patient")
    public ResponseEntity<HistoriquePassageDto> getPassageEnCours(
            @PathVariable UUID idPatient) {
        HistoriquePassageDto passage = patientService.getPassageEnCours(idPatient);
        if (passage == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(passage);
    }

    @GetMapping("/{idPatient}/qr-code")
    @Operation(summary = "Générer l'image QR code du patient")
    public ResponseEntity<byte[]> genererQRCode(@PathVariable UUID idPatient) {
        Patient patient = patientRepository.findById(idPatient)
                .orElseThrow(() -> new ResourceNotFoundException("Patient non trouvé"));
        if (patient.getCarteNumerique() == null) {
            throw new RuntimeException("Aucune carte QR associée à ce patient");
        }
        byte[] qrCodeImage = patientService.genererImageQR(
                patient.getCarteNumerique().getQrCodeToken());
        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_PNG)
                .body(qrCodeImage);
    }
}