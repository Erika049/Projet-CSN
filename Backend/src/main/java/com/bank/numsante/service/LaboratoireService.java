package com.bank.numsante.service;

import com.bank.numsante.dto.ExamenDuJourDto;
import com.bank.numsante.dto.ExamenRequest;
import com.bank.numsante.dto.PassageEnAttenteDto;
import com.bank.numsante.entity.ExamenLaboratoire;
import com.bank.numsante.entity.PassageMedical;
import com.bank.numsante.entity.PersonnelMedical;
import com.bank.numsante.repository.ExamenLaboratoireRepository;
import com.bank.numsante.repository.PassageMedicalRepository;
import com.bank.numsante.repository.PersonnelMedicalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LaboratoireService {

    private final ExamenLaboratoireRepository examenRepo;
    private final PassageMedicalRepository    passageRepo;
    private final PersonnelMedicalRepository  personnelRepo;
    private final LogService                  logService;
    private final NotificationService         notificationService;

    // ── Ajouter un examen ─────────────────────────
    public void ajouterExamen(ExamenRequest request,
                              String username) {
        PassageMedical passage = passageRepo
                .findById(UUID.fromString(
                        request.getIdPassage()))
                .orElseThrow(() -> new RuntimeException(
                        "Passage introuvable"));

        PersonnelMedical laborantin = getLaborantin(username);

        ExamenLaboratoire examen = new ExamenLaboratoire();
        examen.setPassage(passage);
        examen.setLaborantin(laborantin);
        examen.setTypeExamen(request.getTypeExamen());
        examen.setResultats(request.getResultats());
        examenRepo.save(examen);

        logService.logAction(
                laborantin.getIdPersonnel(),
                passage.getPatient().getIdPatient(),
                "AJOUT_EXAMEN",
                passage.getIdPassage());

        notificationService.creerNotification(
                passage.getPatient().getIdPatient(),
                "Nouveaux résultats d'examen",
                request.getTypeExamen()
                        + " publié par le laboratoire",
                "examen");
    }

    // ── Passages en attente d'examen ──────────────
    public List<PassageEnAttenteDto> getPassagesEnAttente(
            String username) {
        PersonnelMedical laborantin = getLaborantin(username);

        // Passages en cours dans l'hôpital du laborantin
        LocalDateTime debut =
                LocalDate.now().atStartOfDay();

        List<PassageMedical> passages =
                laborantin.getHopital() != null
                        ? passageRepo
                        .findByHopital_IdHopitalAndDateAdmissionAfterOrderByDateAdmissionDesc(
                                laborantin.getHopital().getIdHopital(),
                                debut)
                        : passageRepo
                        .findByCreateur_IdPersonnelAndDateAdmissionAfterOrderByDateAdmissionDesc(
                                laborantin.getIdPersonnel(), debut);

        return passages.stream()
                .filter(p -> "en_cours".equals(
                        p.getStatutPassage()))
                .map(this::toPassageEnAttenteDto)
                .collect(Collectors.toList());
    }

    // ── Historique examens du laborantin ──────────
    public List<ExamenDuJourDto> getHistoriqueExamens(
            String username) {
        PersonnelMedical laborantin = getLaborantin(username);

        return examenRepo
                .findByLaborantin_IdPersonnelOrderByDateResultatDesc(
                        laborantin.getIdPersonnel())
                .stream()
                .map(this::toExamenDuJourDto)
                .collect(Collectors.toList());
    }

    // ── Stats du laborantin ───────────────────────
    public Map<String, Long> getStats(String username) {
        PersonnelMedical laborantin = getLaborantin(username);
        long total = examenRepo
                .countByLaborantin_IdPersonnel(
                        laborantin.getIdPersonnel());
        long enAttente = getPassagesEnAttente(username)
                .size();
        return Map.of(
                "total",     total,
                "en_attente", enAttente
        );
    }

    // ── Helpers ───────────────────────────────────

    private PersonnelMedical getLaborantin(
            String username) {
        return personnelRepo
                .findByIdentifiantPro(username)
                .orElseThrow(() -> new RuntimeException(
                        "Laborantin non trouvé"));
    }

    private PassageEnAttenteDto toPassageEnAttenteDto(
            PassageMedical p) {
        var patient = p.getPatient();
        int age = Period.between(
                patient.getDateNaissance(),
                LocalDate.now()).getYears();
        String heure = p.getDateAdmission()
                .format(DateTimeFormatter
                        .ofPattern("HH:mm"));
        return new PassageEnAttenteDto(
                p.getIdPassage(),
                patient.getIdPatient(),
                patient.getNom(),
                patient.getPrenom(),
                p.getMotifVisite(),
                heure,
                p.getHopital() != null
                        ? p.getHopital().getNom() : "",
                age,
                patient.getGroupeSanguin() != null
                        ? patient.getGroupeSanguin() : "",
                p.getDateAdmission()
        );
    }

    private ExamenDuJourDto toExamenDuJourDto(
            ExamenLaboratoire e) {
        var patient = e.getPassage().getPatient();
        int age = Period.between(
                patient.getDateNaissance(),
                LocalDate.now()).getYears();
        return new ExamenDuJourDto(
                e.getIdExamen(),
                e.getPassage().getIdPassage(),
                patient.getIdPatient(),
                patient.getNom(),
                patient.getPrenom(),
                e.getTypeExamen(),
                e.getResultats(),
                e.getDateResultat(),
                e.getPassage().getHopital() != null
                        ? e.getPassage().getHopital()
                        .getNom() : "",
                age,
                patient.getGroupeSanguin() != null
                        ? patient.getGroupeSanguin() : ""
        );
    }
}