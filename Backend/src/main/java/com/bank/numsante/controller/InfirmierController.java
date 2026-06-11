package com.bank.numsante.controller;

import com.bank.numsante.dto.ActiviteInfirmierDto;
import com.bank.numsante.dto.InfirmierDashboardDto;
import com.bank.numsante.service.InfirmierService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/infirmier")
@RequiredArgsConstructor
public class InfirmierController {

    private final InfirmierService infirmierService;

    @Operation(summary = "Dashboard infirmier : profil + passages du jour + stats")
    @GetMapping("/dashboard/{idPersonnel}")
    public ResponseEntity<InfirmierDashboardDto> getDashboard(
            @PathVariable Long idPersonnel) {
        return ResponseEntity.ok(infirmierService.getDashboard(idPersonnel));
    }

    @Operation(summary = "Activité de l'infirmier : constantes prises sur une période")
    @GetMapping("/activite/{idPersonnel}")
    public ResponseEntity<ActiviteInfirmierDto> getActivite(
            @PathVariable Long idPersonnel,
            @RequestParam(defaultValue = "1") int jours) {
        return ResponseEntity.ok(infirmierService.getActivite(idPersonnel, jours));
    }
}
