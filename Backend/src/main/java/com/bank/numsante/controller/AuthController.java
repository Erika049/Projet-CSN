package com.bank.numsante.controller;

import com.bank.numsante.dto.*;
import com.bank.numsante.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "Connexion professionnel (identifiant/mot de passe)")
    @PostMapping("/login-professionnel")
    public ResponseEntity<LoginResponseDto> loginProfessionnel(
            @Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.loginProfessionnel(request));
    }

    @Operation(summary = "Connexion patient (identifiant/mot de passe)")
    @PostMapping("/login-patient")
    public ResponseEntity<LoginResponseDto> loginPatient(
            @Valid @RequestBody LoginPatientRequest request) {
        return ResponseEntity.ok(authService.loginPatient(request));
    }

    @Operation(summary = "Enregistrement de la biométrie (clé publique)")
    @PostMapping("/enregistrer-biometrie")
    public ResponseEntity<Map<String, String>> enregistrerBiometrie(
            @Valid @RequestBody BiometricRegistrationRequest request) {
        authService.enregistrerBiometrie(request);
        return ResponseEntity.ok(Map.of(
                "statut", "success",
                "message", "Authentification biométrique configurée"
        ));
    }

    @Operation(summary = "Connexion biométrique")
    @PostMapping("/login-biometrique")
    public ResponseEntity<LoginResponseDto> loginBiometrique(
            @Valid @RequestBody BiometricLoginRequest request) {
        return ResponseEntity.ok(authService.loginBiometrique(request));
    }
}