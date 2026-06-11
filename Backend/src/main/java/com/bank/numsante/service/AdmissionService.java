package com.bank.numsante.service;

import com.bank.numsante.dto.*;
import com.bank.numsante.entity.*;
import com.bank.numsante.repository.*;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.bank.numsante.entity.LogTracabilite;
import com.bank.numsante.repository.LogTracabiliteRepository;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdmissionService {

    private final CarteNumeriqueRepository     carteRepo;
    private final PatientRepository            patientRepo;
    private final HopitalRepository            hopitalRepo;
    private final PersonnelMedicalRepository   personnelRepo;
    private final PassageMedicalRepository     passageRepo;
    private final LogTracabiliteRepository     logTracabiliteRepo;
    private final LogService                   logService;
    private final HttpServletRequest           httpServletRequest;
    private final NotificationService          notificationService;

    // ── Scan QR ─────────────────────────────────────────────────────────────

    public PatientInfoDto scanCarte(QrScanRequest request, String identifiantAgent) {
        CarteNumerique carte = carteRepo.findByQrCodeToken(request.getQrCodeToken())
                .orElseThrow(() -> new RuntimeException("Carte invalide ou inexistante"));
        Patient patient = carte.getPatient();

        // Résoudre l'ID de l'agent pour le log
        Long idAgent = null;
        if (identifiantAgent != null) {
            idAgent = personnelRepo.findByIdentifiantPro(identifiantAgent)
                    .map(p -> p.getIdPersonnel()).orElse(null);
        }
        logService.logAction(idAgent, patient.getIdPatient(), "SCAN_QR_CODE", null);

        List<PassageMedical> passages = passageRepo
                .findByPatient_IdPatientOrderByDateAdmissionDesc(patient.getIdPatient());
        String dernierPassage = passages.isEmpty() ? null :
                passages.get(0).getDateAdmission()
                        .format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));

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

    // ── Créer passage ────────────────────────────────────────────────────────

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

    // ── Activité de l'agent ──────────────────────────────────────────────────

    public ActiviteAgentDto getActivite(Long idPersonnel, int jours) {
        LocalDateTime depuis = jours == 1
                ? LocalDate.now().atStartOfDay()
                : LocalDateTime.now().minusDays(jours);

        DateTimeFormatter dateFmt  = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        DateTimeFormatter heureFmt = DateTimeFormatter.ofPattern("HH:mm");

        List<PassageMedical> passages    = passageRepo.findByCreateurSince(idPersonnel, depuis);
        List<LogTracabilite> patientLogs = logTracabiliteRepo.findPatientCreationsBy(idPersonnel, depuis);

        // Paires (date, item) pour tri global
        record TimedItem(LocalDateTime dt, ActiviteItemDto item) {}
        List<TimedItem> combined = new ArrayList<>();

        // Passages → SCAN ou URGENCE
        for (PassageMedical p : passages) {
            boolean urgence = p.getMotifVisite() != null
                    && p.getMotifVisite().toLowerCase().contains("urgence");
            combined.add(new TimedItem(
                    p.getDateAdmission(),
                    new ActiviteItemDto(
                            p.getIdPassage().toString(),
                            p.getPatient().getNom(),
                            p.getPatient().getPrenom(),
                            p.getMotifVisite(),
                            p.getDateAdmission().format(dateFmt),
                            p.getDateAdmission().format(heureFmt),
                            p.getStatutPassage(),
                            urgence,
                            urgence ? "URGENCE" : "SCAN"
                    )
            ));
        }

        // Logs CREATION_PATIENT → NOUVEAU_PATIENT
        for (LogTracabilite log : patientLogs) {
            String nom = "—", prenom = "";
            if (log.getIdPatient() != null) {
                var patOpt = patientRepo.findById(log.getIdPatient());
                if (patOpt.isPresent()) {
                    nom    = patOpt.get().getNom();
                    prenom = patOpt.get().getPrenom();
                }
            }
            combined.add(new TimedItem(
                    log.getHorodatage(),
                    new ActiviteItemDto(
                            null, nom, prenom,
                            "Inscription CSN",
                            log.getHorodatage().format(dateFmt),
                            log.getHorodatage().format(heureFmt),
                            "inscrit", false, "NOUVEAU_PATIENT"
                    )
            ));
        }

        // Tri date décroissante
        combined.sort((a, b) -> b.dt().compareTo(a.dt()));
        List<ActiviteItemDto> items = combined.stream()
                .map(TimedItem::item).collect(Collectors.toList());

        // Tous les passages démarrent par un scan QR — urgents ou non
        int nbScans     = (int) passages.size();
        int nbCreations = (int) items.stream().filter(i -> "NOUVEAU_PATIENT".equals(i.getType())).count();
        int nbUrgences  = (int) items.stream().filter(i -> "URGENCE".equals(i.getType())).count();

        logService.logAction(idPersonnel, null, "LECTURE_ACTIVITE_AGENT", null);

        return new ActiviteAgentDto(items.size(), nbScans, nbCreations, nbUrgences, items);
    }

    // ── Dashboard agent d'accueil ────────────────────────────────────────────

    public DashboardAccueilDto getDashboard(Long idPersonnel) {
        PersonnelMedical agent = personnelRepo.findById(idPersonnel)
                .orElseThrow(() -> new RuntimeException("Personnel non trouvé : " + idPersonnel));

        Long idHopital = agent.getHopital() != null ? agent.getHopital().getIdHopital() : null;
        String nomHopital = agent.getHopital() != null ? agent.getHopital().getNom() : "Établissement";

        List<PassageMedical> passages = idHopital != null
                ? passageRepo.findPassagesDuJour(idHopital)
                : List.of();

        int enAttente = (int) passages.stream()
                .filter(p -> "en_cours".equals(p.getStatutPassage()))
                .count();

        int urgences = (int) passages.stream()
                .filter(p -> p.getMotifVisite() != null
                        && p.getMotifVisite().toLowerCase().contains("urgence"))
                .count();

        List<DashboardAdmissionDto> dtos = passages.stream()
                .map(p -> new DashboardAdmissionDto(
                        p.getIdPassage().toString(),
                        p.getPatient().getNom(),
                        p.getPatient().getPrenom(),
                        p.getMotifVisite(),
                        p.getDateAdmission().format(DateTimeFormatter.ofPattern("HH:mm")),
                        p.getStatutPassage(),
                        p.getMotifVisite() != null
                                && p.getMotifVisite().toLowerCase().contains("urgence")
                ))
                .collect(Collectors.toList());

        logService.logAction(idPersonnel, null, "LECTURE_DASHBOARD_ACCUEIL", null);

        return new DashboardAccueilDto(
                agent.getPrenom(),
                agent.getNom(),
                nomHopital,
                passages.size(),
                enAttente,
                urgences,
                dtos
        );
    }
}
