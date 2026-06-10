package com.bank.numsante.controller;

import com.bank.numsante.dto.NotificationDto;
import com.bank.numsante.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/patient/{idPatient}")
    @Operation(summary = "Toutes les notifications d'un patient")
    public ResponseEntity<List<NotificationDto>> getNotifications(
            @PathVariable UUID idPatient) {
        return ResponseEntity.ok(
                notificationService.getNotifications(idPatient));
    }

    @GetMapping("/patient/{idPatient}/non-lues")
    @Operation(summary = "Nombre de notifications non lues")
    public ResponseEntity<Map<String, Long>> getNombreNonLues(
            @PathVariable UUID idPatient) {
        return ResponseEntity.ok(Map.of(
                "count",
                notificationService.getNombreNonLues(idPatient)));
    }

    @PutMapping("/patient/{idPatient}/tout-lire")
    @Operation(summary = "Marquer toutes les notifications comme lues")
    public ResponseEntity<Map<String, String>> marquerToutesLues(
            @PathVariable UUID idPatient) {
        notificationService.marquerToutesLues(idPatient);
        return ResponseEntity.ok(
                Map.of("message", "Toutes les notifications marquées comme lues"));
    }

    @PutMapping("/{idNotification}/lire")
    @Operation(summary = "Marquer une notification comme lue")
    public ResponseEntity<Map<String, String>> marquerLue(
            @PathVariable Long idNotification) {
        notificationService.marquerLue(idNotification);
        return ResponseEntity.ok(
                Map.of("message", "Notification marquée comme lue"));
    }
}