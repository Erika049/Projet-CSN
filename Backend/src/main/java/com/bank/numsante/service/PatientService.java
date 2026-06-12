package com.bank.numsante.service;

import com.bank.numsante.dto.*;
import com.bank.numsante.entity.*;
import com.bank.numsante.repository.*;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PatientService {

    private final PassageMedicalRepository passageRepo;
    private final ExamenLaboratoireRepository examenRepo;
    private final LogService logService;
    private final CarteNumeriqueRepository carteNumeriqueRepository;
    private final PatientRepository patientRepository;
    private final PasswordEncoder passwordEncoder;

    // ======================== PROFIL ========================

    public PatientProfilDto getProfil(UUID idPatient) {
        Patient patient = patientRepository.findById(idPatient)
                .orElseThrow(() -> new RuntimeException("Patient non trouvé"));

        CarteNumerique carte = patient.getCarteNumerique();

        logService.logAction(null, idPatient, "LECTURE_PROFIL", null);

        return new PatientProfilDto(
                patient.getIdPatient(),
                patient.getNom(),
                patient.getPrenom(),
                patient.getDateNaissance(),
                patient.getGenre(),
                patient.getGroupeSanguin(),
                patient.getTelephone(),
                patient.getEmail(),
                patient.getAdresse(),
                patient.getUrgenceNom(),
                patient.getUrgenceTelephone(),
                carte != null ? carte.getQrCodeToken() : null,
                carte != null ? carte.getStatut() : null,
                carte != null ? carte.getExpireLe() : null
        );
    }

    // ======================== HISTORIQUE ========================

    public List<HistoriquePassageDto> getHistorique(UUID idPatient) {
        List<PassageMedical> passages = passageRepo
                .findByPatient_IdPatientOrderByDateAdmissionDesc(idPatient);

        logService.logAction(null, idPatient, "LECTURE_HISTORIQUE", null);

        return passages.stream()
                .map(this::toHistoriqueDto)
                .collect(Collectors.toList());
    }

    // ======================== PASSAGE EN COURS ========================

    public HistoriquePassageDto getPassageEnCours(UUID idPatient) {
        List<PassageMedical> passages = passageRepo
                .findByPatient_IdPatientOrderByDateAdmissionDesc(idPatient);

        return passages.stream()
                .filter(p -> "en_cours".equals(p.getStatutPassage()))
                .findFirst()
                .map(this::toHistoriqueDto)
                .orElse(null);
    }

    // ======================== INSCRIPTION ========================

    @Transactional
    public Map<String, Object> enregistrerPatient(EnregistrementPatientRequest request) {
        // Vérifications unicité
        if (patientRepository.existsByIdentifiant(request.getIdentifiant())) {
            throw new RuntimeException("Cet identifiant est déjà utilisé");
        }
        if (patientRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Cet email est déjà utilisé");
        }

        // Créer le patient
        Patient patient = new Patient();
        patient.setNom(request.getNom());
        patient.setPrenom(request.getPrenom());
        patient.setDateNaissance(request.getDateNaissance());
        patient.setGenre(request.getGenre());
        patient.setGroupeSanguin(request.getGroupeSanguin());
        patient.setTelephone(request.getTelephone());
        patient.setEmail(request.getEmail());
        patient.setAdresse(request.getAdresse());
        patient.setIdentifiant(request.getIdentifiant());
        patient.setMotDePasseHash(passwordEncoder.encode(request.getMotDePasse()));
        patient.setUrgenceNom(request.getUrgenceNom());
        patient.setUrgenceTelephone(request.getUrgenceTelephone());
        patient = patientRepository.save(patient);

        // Générer QR token
        String qrToken = genererTokenQR(patient.getIdPatient());

        // Créer la carte numérique
        CarteNumerique carte = new CarteNumerique();
        carte.setPatient(patient);
        carte.setQrCodeToken(qrToken);
        carte.setStatut("actif");
        carte.setExpireLe(LocalDate.now().plusYears(2));
        carteNumeriqueRepository.save(carte);

        // Log
        logService.logAction(null, patient.getIdPatient(),
                "CREATION_PATIENT_ET_QR", null);

        // Réponse
        Map<String, Object> response = new HashMap<>();
        response.put("idPatient", patient.getIdPatient());
        response.put("nom", patient.getNom());
        response.put("prenom", patient.getPrenom());
        response.put("identifiant", patient.getIdentifiant());
        response.put("qrCodeToken", qrToken);
        response.put("dateExpiration", carte.getExpireLe());
        response.put("message", "Patient enregistré avec succès. QR code généré.");
        return response;
    }

    // ======================== HELPERS ========================

    private HistoriquePassageDto toHistoriqueDto(PassageMedical p) {
        // Récupérer les examens liés
        List<ExamenLaboratoire> examens = examenRepo
                .findByPassage_IdPassage(p.getIdPassage());

        List<HistoriquePassageDto.ExamenDto> examenDtos = examens.stream()
                .map(e -> new HistoriquePassageDto.ExamenDto(
                        e.getIdExamen(),
                        e.getTypeExamen(),
                        e.getResultats(),
                        e.getDateResultat()
                ))
                .collect(Collectors.toList());

        return new HistoriquePassageDto(
                p.getIdPassage(),
                p.getHopital().getNom(),
                p.getMotifVisite(),
                p.getCreateur().getPrenom() + " " + p.getCreateur().getNom(),
                p.getDateAdmission(),
                p.getMotifVisite(),
                p.getConstantesVitales(),
                p.getDiagnostic(),
                p.getPrescriptionOrdonnance(),
                p.getStatutPassage(),
                examenDtos
        );
    }

    private String genererTokenQR(UUID patientId) {
        String rawToken = patientId.toString() + "-" +
                System.currentTimeMillis() + "-" + UUID.randomUUID();
        return Base64.getUrlEncoder().withoutPadding()
                .encodeToString(rawToken.getBytes());
    }

    public byte[] genererImageQR(String token) {
        try {
            int width = 300;
            int height = 300;
            BitMatrix bitMatrix = new QRCodeWriter().encode(
                    token, BarcodeFormat.QR_CODE, width, height);
            BufferedImage image = new BufferedImage(
                    width, height, BufferedImage.TYPE_INT_RGB);
            for (int x = 0; x < width; x++) {
                for (int y = 0; y < height; y++) {
                    image.setRGB(x, y, bitMatrix.get(x, y) ?
                            Color.BLACK.getRGB() : Color.WHITE.getRGB());
                }
            }
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(image, "png", baos);
            return baos.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Erreur génération QR code", e);
        }
    }
}