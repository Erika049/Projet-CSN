package com.bank.numsante.service;

import com.bank.numsante.dto.ActiviteProDto;
import com.bank.numsante.dto.PassageDetailDto;
import com.bank.numsante.dto.PatientDuJourDto;
import com.bank.numsante.entity.PassageMedical;
import com.bank.numsante.entity.PersonnelMedical;
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
public class MedecinService {

    private final PassageMedicalRepository passageRepo;
    private final PersonnelMedicalRepository personnelRepo;

    // ── Patients du jour ──────────────────────────────
    public List<PatientDuJourDto> getPatientsDuJour(String username) {
        PersonnelMedical medecin = getMedecin(username);
        LocalDateTime debutJour = LocalDate.now().atStartOfDay();

        List<PassageMedical> passages =
                medecin.getHopital() != null
                        ? passageRepo
                        .findByHopital_IdHopitalAndDateAdmissionAfterOrderByDateAdmissionDesc(
                                medecin.getHopital().getIdHopital(), debutJour)
                        : passageRepo
                        .findByCreateur_IdPersonnelAndDateAdmissionAfterOrderByDateAdmissionDesc(
                                medecin.getIdPersonnel(), debutJour);

        return passages.stream()
                .map(this::toPatientDuJourDto)
                .collect(Collectors.toList());
    }

    // ── Stats du jour ─────────────────────────────────
    public Map<String, Integer> getStatsDuJour(String username) {
        List<PatientDuJourDto> patients = getPatientsDuJour(username);
        int total    = patients.size();
        int enCours  = (int) patients.stream()
                .filter(p -> "en_cours".equals(p.getStatut()))
                .count();
        int urgences = (int) patients.stream()
                .filter(p -> "urgence".equals(p.getStatut()))
                .count();
        return Map.of(
                "total",    total,
                "en_cours", enCours,
                "urgences", urgences
        );
    }

    // ── Détail d'un passage ───────────────────────────
    public PassageDetailDto getPassageDetail(UUID idPassage) {
        PassageMedical p = passageRepo.findById(idPassage)
                .orElseThrow(() ->
                        new RuntimeException("Passage introuvable"));
        return toPassageDetailDto(p);
    }

    // ── Activité du médecin ───────────────────────────
    public List<ActiviteProDto> getActivite(String username,
                                            int jours) {
        PersonnelMedical medecin = getMedecin(username);
        LocalDateTime debut = jours == 0
                ? LocalDate.now().atStartOfDay()
                : LocalDateTime.now().minusDays(jours);

        return passageRepo
                .findByCreateur_IdPersonnelAndDateAdmissionAfterOrderByDateAdmissionDesc(
                        medecin.getIdPersonnel(), debut)
                .stream()
                .map(this::toActiviteDto)
                .collect(Collectors.toList());
    }

    // ── Helpers ───────────────────────────────────────

    private PersonnelMedical getMedecin(String username) {
        return personnelRepo.findByIdentifiantPro(username)
                .orElseThrow(() ->
                        new RuntimeException("Médecin non trouvé"));
    }

    private PatientDuJourDto toPatientDuJourDto(PassageMedical p) {
        var patient = p.getPatient();
        int age = Period.between(
                patient.getDateNaissance(),
                LocalDate.now()).getYears();
        String heure = p.getDateAdmission()
                .format(DateTimeFormatter.ofPattern("HH:mm"));
        return new PatientDuJourDto(
                p.getIdPassage(),
                patient.getIdPatient(),
                patient.getNom(),
                patient.getPrenom(),
                p.getMotifVisite(),
                heure,
                p.getStatutPassage(),
                patient.getGroupeSanguin() != null
                        ? patient.getGroupeSanguin() : "",
                age
        );
    }

    private PassageDetailDto toPassageDetailDto(PassageMedical p) {
        return new PassageDetailDto(
                p.getIdPassage(),
                p.getPatient().getNom(),
                p.getPatient().getPrenom(),
                p.getPatient().getIdPatient(),
                p.getHopital() != null
                        ? p.getHopital().getNom() : "",
                p.getMotifVisite(),
                p.getDateAdmission(),
                p.getStatutPassage(),
                p.getConstantesVitales(),
                p.getDiagnostic(),
                p.getPrescriptionOrdonnance()
        );
    }

    private ActiviteProDto toActiviteDto(PassageMedical p) {
        String type  = p.getDiagnostic() != null
                ? "consult" : "admission";
        String label = p.getDiagnostic() != null
                ? "Consultation " + p.getMotifVisite()
                : "Admission "    + p.getMotifVisite();
        String patient = p.getPatient().getPrenom()
                + " " + p.getPatient().getNom();
        String detail = p.getDiagnostic() != null
                ? p.getDiagnostic() : p.getMotifVisite();
        return new ActiviteProDto(
                p.getIdPassage(),
                type,
                label,
                patient,
                detail,
                "primary",
                p.getDateAdmission()
        );
    }
}