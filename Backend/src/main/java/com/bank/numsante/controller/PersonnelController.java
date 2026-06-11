package com.bank.numsante.controller;

import com.bank.numsante.dto.PersonnelProfilDto;
import com.bank.numsante.service.PersonnelService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/personnel")
@RequiredArgsConstructor
public class PersonnelController {

    private final PersonnelService personnelService;

    @GetMapping("/{idPersonnel}/profil")
    @Operation(summary = "Profil du personnel médical (médecin, infirmier, accueil, pharmacien…)")
    public ResponseEntity<PersonnelProfilDto> getProfil(
            @PathVariable Long idPersonnel) {
        return ResponseEntity.ok(personnelService.getProfil(idPersonnel));
    }
}
