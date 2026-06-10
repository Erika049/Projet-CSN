package com.bank.numsante.service;

import com.bank.numsante.config.JwtTokenProvider;
import com.bank.numsante.dto.*;
import com.bank.numsante.entity.Patient;
import com.bank.numsante.entity.PersonnelMedical;
import com.bank.numsante.repository.PatientRepository;
import com.bank.numsante.repository.PersonnelMedicalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final PersonnelMedicalRepository personnelRepo;
    private final PatientRepository patientRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public LoginResponseDto loginProfessionnel(LoginRequest request) {
        PersonnelMedical personnel = personnelRepo.findByIdentifiantPro(request.getIdentifiantPro())
                .orElseThrow(() -> new RuntimeException("Identifiants invalides"));
        if (!passwordEncoder.matches(request.getMotDePasse(), personnel.getMotDePasseHash())) {
            throw new RuntimeException("Identifiants invalides");
        }
        String token = jwtTokenProvider.generateToken(
                personnel.getIdentifiantPro(), personnel.getRole());
        return new LoginResponseDto(
                token,
                personnel.getRole(),
                String.valueOf(personnel.getIdPersonnel()),
                personnel.getNom(),
                personnel.getPrenom()
        );
    }

    public LoginResponseDto loginPatient(LoginPatientRequest request) {
        Patient patient = patientRepo.findByIdentifiant(request.getIdentifiant())
                .orElseThrow(() -> new RuntimeException("Identifiants invalides"));
        if (patient.getMotDePasseHash() == null ||
                !passwordEncoder.matches(request.getMotDePasse(), patient.getMotDePasseHash())) {
            throw new RuntimeException("Identifiants invalides");
        }
        String token = jwtTokenProvider.generateToken(
                patient.getIdPatient().toString(), "patient");
        return new LoginResponseDto(
                token,
                "patient",
                patient.getIdPatient().toString(),
                patient.getNom(),
                patient.getPrenom()
        );
    }

    public void enregistrerBiometrie(BiometricRegistrationRequest request) {
        if ("patient".equals(request.getTypeUtilisateur())) {
            Patient patient = patientRepo.findById(
                            java.util.UUID.fromString(request.getIdUtilisateur()))
                    .orElseThrow(() -> new RuntimeException("Patient introuvable"));
            patient.setClePubliqueBiometrique(request.getClePubliqueAppareil());
            patientRepo.save(patient);
        } else if ("personnel".equals(request.getTypeUtilisateur())) {
            PersonnelMedical personnel = personnelRepo.findById(
                            Long.parseLong(request.getIdUtilisateur()))
                    .orElseThrow(() -> new RuntimeException("Personnel introuvable"));
            personnel.setClePubliqueAppareil(request.getClePubliqueAppareil());
            personnelRepo.save(personnel);
        } else {
            throw new RuntimeException("Type utilisateur invalide");
        }
    }

    public LoginResponseDto loginBiometrique(BiometricLoginRequest request) {
        // Chercher d'abord dans les patients
        try {
            Patient patient = patientRepo.findById(
                            java.util.UUID.fromString(request.getIdUtilisateur()))
                    .orElse(null);
            if (patient != null && patient.getClePubliqueBiometrique() != null) {
                if (!request.getSignatureDefi().isBlank()) {
                    String token = jwtTokenProvider.generateToken(
                            patient.getIdPatient().toString(), "patient");
                    return new LoginResponseDto(
                            token, "patient",
                            patient.getIdPatient().toString(),
                            patient.getNom(), patient.getPrenom()
                    );
                }
            }
        } catch (IllegalArgumentException ignored) {}

        // Chercher dans le personnel
        PersonnelMedical personnel = personnelRepo.findById(
                        Long.parseLong(request.getIdUtilisateur()))
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));
        if (personnel.getClePubliqueAppareil() != null &&
                !request.getSignatureDefi().isBlank()) {
            String token = jwtTokenProvider.generateToken(
                    personnel.getIdentifiantPro(), personnel.getRole());
            return new LoginResponseDto(
                    token, personnel.getRole(),
                    String.valueOf(personnel.getIdPersonnel()),
                    personnel.getNom(), personnel.getPrenom()
            );
        }
        throw new RuntimeException("Authentification biométrique échouée");
    }
}