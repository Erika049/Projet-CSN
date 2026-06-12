package com.bank.numsante.service;

import com.bank.numsante.dto.*;
import com.bank.numsante.entity.Hopital;
import com.bank.numsante.entity.PersonnelMedical;
import com.bank.numsante.entity.LogTracabilite;
import com.bank.numsante.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final PersonnelMedicalRepository  personnelRepo;
    private final HopitalRepository           hopitalRepo;
    private final PatientRepository           patientRepo;
    private final PassageMedicalRepository    passageRepo;
    private final ExamenLaboratoireRepository examenRepo;
    private final LogTracabiliteRepository    logRepo;
    private final PasswordEncoder             encoder;

    // ── Stats globales ────────────────────────────
    public AdminStatsDto getStats() {
        LocalDateTime debutJour =
                LocalDate.now().atStartOfDay();

        long nbPassagesAujourdhui = passageRepo
                .findAll()
                .stream()
                .filter(p -> p.getDateAdmission()
                        .isAfter(debutJour))
                .count();

        long nbExamensAujourdhui = examenRepo
                .findAll()
                .stream()
                .filter(e -> e.getDateResultat()
                        .isAfter(debutJour))
                .count();

        return new AdminStatsDto(
                patientRepo.count(),
                personnelRepo.count(),
                hopitalRepo.count(),
                nbPassagesAujourdhui,
                nbExamensAujourdhui
        );
    }

    // ── Personnel ─────────────────────────────────
    public List<PersonnelDto> getPersonnel() {
        return personnelRepo.findAll()
                .stream()
                .map(this::toPersonnelDto)
                .collect(Collectors.toList());
    }

    public PersonnelDto creerPersonnel(
            CreerPersonnelRequest request) {
        Hopital hopital = hopitalRepo
                .findById(request.getIdHopital())
                .orElseThrow(() ->
                        new RuntimeException(
                                "Hôpital introuvable"));

        PersonnelMedical p = new PersonnelMedical();
        p.setNom(request.getNom());
        p.setPrenom(request.getPrenom());
        p.setRole(request.getRole());
        p.setIdentifiantPro(
                request.getIdentifiantPro());
        p.setMotDePasseHash(
                encoder.encode(
                        request.getMotDePasse()));
        p.setHopital(hopital);
        p.setEstActif(true);

        return toPersonnelDto(
                personnelRepo.save(p));
    }

    public PersonnelDto toggleActif(
            Long idPersonnel) {
        PersonnelMedical p = personnelRepo
                .findById(idPersonnel)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Personnel introuvable"));
        p.setEstActif(!p.getEstActif());
        return toPersonnelDto(
                personnelRepo.save(p));
    }

    // ── Hôpitaux ──────────────────────────────────
    public List<HopitalDto> getHopitaux() {
        return hopitalRepo.findAll()
                .stream()
                .map(this::toHopitalDto)
                .collect(Collectors.toList());
    }

    public HopitalDto creerHopital(
            CreerHopitalRequest request) {
        Hopital h = new Hopital();
        h.setNom(request.getNom());
        h.setAdresse(request.getAdresse());
        h.setCodeUnique(request.getCodeUnique());
        return toHopitalDto(hopitalRepo.save(h));
    }

    // ── Logs ──────────────────────────────────────
    public List<LogDto> getLogs(int limit) {
        return logRepo
                .findAllByOrderByHorodatageDesc(
                        PageRequest.of(0, limit))
                .stream()
                .map(this::toLogDto)
                .collect(Collectors.toList());
    }

    // ── Mappers ───────────────────────────────────
    private PersonnelDto toPersonnelDto(
            PersonnelMedical p) {
        return new PersonnelDto(
                p.getIdPersonnel(),
                p.getNom(),
                p.getPrenom(),
                p.getRole(),
                p.getIdentifiantPro(),
                p.getHopital() != null
                        ? p.getHopital().getNom()
                        : "",
                p.getHopital() != null
                        ? p.getHopital().getIdHopital()
                        : null,
                p.getEstActif()
        );
    }

    private HopitalDto toHopitalDto(Hopital h) {
        int nb = h.getPersonnels() != null
                ? h.getPersonnels().size() : 0;
        return new HopitalDto(
                h.getIdHopital(),
                h.getNom(),
                h.getAdresse(),
                h.getCodeUnique(),
                nb
        );
    }
    private LogDto toLogDto(LogTracabilite l) {
        String nomPersonnel =
                l.getPersonnel() != null
                        ? l.getPersonnel().getPrenom()
                        + " " + l.getPersonnel().getNom()
                        : l.getIdUtilisateur() != null
                        ? "Personnel #"
                        + l.getIdUtilisateur()
                        : "Système";
        return new LogDto(
                l.getIdLog(),
                nomPersonnel,
                l.getIdPatient(),
                l.getActionEffectuee(),
                l.getAdresseIp(),
                l.getHorodatage()
        );
    }
}