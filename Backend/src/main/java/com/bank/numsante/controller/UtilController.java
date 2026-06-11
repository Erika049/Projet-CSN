package com.bank.numsante.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Endpoint utilitaire DEV — à supprimer avant la mise en production.
 * Génère un hash BCrypt compatible Spring pour l'insertion en base.
 */
@RestController
@RequestMapping("/api/v1/util")
@RequiredArgsConstructor
public class UtilController {

    private final PasswordEncoder encoder;

    @GetMapping("/hash")
    public Map<String, String> hash(@RequestParam String password) {
        return Map.of("hash", encoder.encode(password));
    }
}
