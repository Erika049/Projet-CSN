package com.bank.numsante.service;

import com.bank.numsante.dto.*;
import com.bank.numsante.entity.*;
import com.bank.numsante.repository.*;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdmissionService {

    private final CarteNumeriqueRepository carteRepo;
    private final PatientRepository patientRepo;
    private final HopitalRepository hopitalRepo;
    private final PersonnelMedicalRepository personnelRepo;
    private final PassageMedicalRepository passageRepo;
    private final LogService logService;
    private final HttpServletRequest httpServletRequest;
    private final NotificationService notificationService;

    public PatientInfoDto scanCarte(QrScanRequest request) {
        CarteNumerique carte = carteRepo.findByQrCodeToken(request.getQrCodeToken())
                .orElseThrow(() -> new RuntimeException("Carte invalide ou inexistante"));
        Patient patient = carte.getPatient();

        logService.logAction(null, patient.getIdPatient(), "SCAN_QR_CODE", null);

        // Dernier passage
        List<PassageMedical> passages = passageRepo
                .findByPatient_IdPatientOrderByDateAdmissionDesc(patient.getIdPatient());
        String dernierPassage = passages.isEmpty() ? null :
                passages.get(0).getDateAdmission()
                        .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));

        return new PatientInfoDto(
                patient.getIdPatient(),
                patient.getNom(),
                patient.getPrenom(),
                patient.getDateNaissance(),
                patient.getGenre(),
                patient.getGroupeSanguin(),
                patient.getTelephone(),
                carte.getStatut(),
                carte.getExpireLe(),
                dernierPassage
        );
    }

    @Transactional
    public UUID creerPassage(CreerPassageRequest request, String username) {
        Patient patient = patientRepo.findById(UUID.fromString(request.getIdPatient()))
                .orElseThrow(() -> new RuntimeException("Patient non trouvé"));
        Hopital hopital = hopitalRepo.findById(request.getIdHopital())
                .orElseThrow(() -> new RuntimeException("Hôpital non trouvé"));
        PersonnelMedical createur = personnelRepo.findByIdentifiantPro(username)
                .orElseThrow(() -> new RuntimeException("Personnel non trouvé"));

        PassageMedical passage = new PassageMedical();
        passage.setPatient(patient);
        passage.setHopital(hopital);
        passage.setCreateur(createur);
        passage.setMotifVisite(request.getMotifVisite());
        passage.setStatutPassage("en_cours");
        passage = passageRepo.save(passage);

        logService.logAction(createur.getIdPersonnel(), patient.getIdPatient(),
                "CREATION_PASSAGE", passage.getIdPassage());

        notificationService.creerNotification(
                patient.getIdPatient(),
                "Admission enregistrée",
                "Hôpital " + hopital.getNom() + " — " + request.getMotifVisite(),
                "admission"
        );

        return passage.getIdPassage();
    }

    // ── Dashboard accueil ────────────────────────────
    @Transactional
    public DashboardAccueilDto getDashboard(Long idPersonnel) {
        PersonnelMedical agent = personnelRepo.findById(idPersonnel)
                .orElseThrow(() -> new RuntimeException("Personnel non trouvé : " + idPersonnel));

        Long   idHopital  = agent.getHopital() != null ? agent.getHopital().getIdHopital() : null;
        String nomHopital = agent.getHopital() != null ? agent.getHopital().getNom() : "Établissement";

        LocalDate debutJour = LocalDate.now();
        LocalDateTime debutDuJour = debutJour.atStartOfDay();

        List<PassageMedical> tousAdmissions = idHopital != null
                ? passageRepo.findByHopital_IdHopitalAndDateAdmissionAfterOrderByDateAdmissionDesc(
                        idHopital, debutDuJour)
                : List.of();

        int totalAdmissions = tousAdmissions.size();
        int enAttente = (int) tousAdmissions.stream()
                .filter(p -> "en_cours".equals(p.getStatutPassage()))
                .count();
        int urgences = (int) tousAdmissions.stream()
                .filter(p -> p.getMotifVisite() != null
                        && p.getMotifVisite().toLowerCase().contains("urgence"))
                .count();

        java.time.format.DateTimeFormatter heureFmt = java.time.format.DateTimeFormatter.ofPattern("HH:mm");

        List<DashboardAdmissionDto> admissions = tousAdmissions.stream()
                .map(p -> new DashboardAdmissionDto(
                        p.getIdPassage().toString(),
                        p.getPatient().getNom(),
                        p.getPatient().getPrenom(),
                        p.getMotifVisite(),
                        p.getDateAdmission().format(heureFmt),
                        p.getStatutPassage(),
                        p.getMotifVisite() != null && p.getMotifVisite().toLowerCase().contains("urgence")
                ))
                .collect(Collectors.toList());

        return new DashboardAccueilDto(
                agent.getPrenom(),
                agent.getNom(),
                nomHopital,
                totalAdmissions,
                enAttente,
                urgences,
                admissions
        );
    }

    // ── Activité agent d'accueil ─────────────────────
    @Transactional
    public ActiviteAgentDto getActivite(Long idPersonnel, int jours) {
        LocalDateTime depuis = jours == 1
                ? LocalDate.now().atStartOfDay()
                : LocalDateTime.now().minusDays(jours);

        java.time.format.DateTimeFormatter dateFmt  = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
        java.time.format.DateTimeFormatter heureFmt = java.time.format.DateTimeFormatter.ofPattern("HH:mm");

        List<PassageMedical> passages = passageRepo
                .findByCreateur_IdPersonnelAndDateAdmissionAfterOrderByDateAdmissionDesc(
                        idPersonnel, depuis);

        int scans = (int) passages.stream()
                .filter(p -> p.getMotifVisite() != null && p.getMotifVisite().toLowerCase().contains("scan"))
                .count();
        int creations = (int) passages.stream()
                .filter(p -> p.getMotifVisite() != null && p.getMotifVisite().toLowerCase().contains("nouveau"))
                .count();
        int urgences = (int) passages.stream()
                .filter(p -> p.getMotifVisite() != null && p.getMotifVisite().toLowerCase().contains("urgence"))
                .count();

        List<ActiviteItemDto> items = passages.stream()
                .map(p -> {
                    String type = p.getMotifVisite() != null
                            && p.getMotifVisite().toLowerCase().contains("nouveau")
                            ? "NOUVEAU_PATIENT"
                            : p.getMotifVisite() != null
                            && p.getMotifVisite().toLowerCase().contains("urgence")
                            ? "URGENCE"
                            : "SCAN";
                    return new ActiviteItemDto(
                            p.getIdPassage().toString(),
                            p.getPatient().getNom(),
                            p.getPatient().getPrenom(),
                            p.getMotifVisite(),
                            p.getDateAdmission().format(dateFmt),
                            p.getDateAdmission().format(heureFmt),
                            p.getStatutPassage(),
                            p.getMotifVisite() != null && p.getMotifVisite().toLowerCase().contains("urgence"),
                            type
                    );
                })
                .collect(Collectors.toList());

        return new ActiviteAgentDto(
                passages.size(),
                scans,
                creations,
                urgences,
                items
        );
    }
}
