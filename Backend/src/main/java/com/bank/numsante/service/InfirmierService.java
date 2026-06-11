package com.bank.numsante.service;

import com.bank.numsante.dto.*;
import com.bank.numsante.entity.LogTracabilite;
import com.bank.numsante.entity.PassageMedical;
import com.bank.numsante.entity.PersonnelMedical;
import com.bank.numsante.repository.LogTracabiliteRepository;
import com.bank.numsante.repository.PassageMedicalRepository;
import com.bank.numsante.repository.PersonnelMedicalRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
@RequiredArgsConstructor
public class InfirmierService {

    private final PersonnelMedicalRepository personnelRepo;
    private final PassageMedicalRepository   passageRepo;
    private final LogTracabiliteRepository   logRepo;

    @Transactional
    public InfirmierDashboardDto getDashboard(Long idPersonnel) {
        PersonnelMedical infirmier = personnelRepo.findById(idPersonnel)
                .orElseThrow(() -> new RuntimeException("Personnel non trouvé : " + idPersonnel));

        Long   idHopital  = infirmier.getHopital() != null ? infirmier.getHopital().getIdHopital() : null;
        String nomHopital = infirmier.getHopital() != null ? infirmier.getHopital().getNom() : "Établissement";

        List<PassageMedical> tous = idHopital != null
                ? passageRepo.findPassagesDuJour(idHopital)
                : List.of();

        List<PassageMedical> enCours = tous.stream()
                .filter(p -> "en_cours".equals(p.getStatutPassage()))
                .collect(Collectors.toList());

        int faits = (int) enCours.stream()
                .filter(p -> p.getConstantesVitales() != null && !p.getConstantesVitales().isEmpty())
                .count();

        int aConstanter = enCours.size() - faits;

        int urgences = (int) enCours.stream()
                .filter(p -> p.getMotifVisite() != null
                        && p.getMotifVisite().toLowerCase().contains("urgence"))
                .count();

        // Les passages sans constantes en premier, urgences prioritaires
        List<PassageInfirmierDto> dtos = enCours.stream()
                .sorted(Comparator
                        .comparing((PassageMedical p) ->
                                p.getConstantesVitales() != null && !p.getConstantesVitales().isEmpty())
                        .thenComparing(p ->
                                !(p.getMotifVisite() != null && p.getMotifVisite().toLowerCase().contains("urgence"))))
                .map(p -> new PassageInfirmierDto(
                        p.getIdPassage().toString(),
                        p.getPatient().getNom(),
                        p.getPatient().getPrenom(),
                        p.getMotifVisite(),
                        p.getDateAdmission().format(DateTimeFormatter.ofPattern("HH:mm")),
                        p.getMotifVisite() != null
                                && p.getMotifVisite().toLowerCase().contains("urgence"),
                        p.getConstantesVitales() != null && !p.getConstantesVitales().isEmpty()
                ))
                .collect(Collectors.toList());

        return new InfirmierDashboardDto(
                infirmier.getPrenom(),
                infirmier.getNom(),
                nomHopital,
                aConstanter,
                urgences,
                faits,
                dtos
        );
    }

    // ── Activité de l'infirmier ──────────────────────────────────────────────

    @Transactional
    public ActiviteInfirmierDto getActivite(Long idPersonnel, int jours) {
        LocalDateTime depuis = jours == 1
                ? LocalDate.now().atStartOfDay()
                : LocalDateTime.now().minusDays(jours);

        DateTimeFormatter dateFmt  = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        DateTimeFormatter heureFmt = DateTimeFormatter.ofPattern("HH:mm");

        List<LogTracabilite> logs = logRepo.findActesInfirmier(idPersonnel, depuis);

        List<ActiviteInfirmierItemDto> items = new ArrayList<>();
        // Pour les constantes : déduplique par passage (garde le plus récent)
        Set<UUID> seenConstantes = new HashSet<>();
        int constantes = 0, soins = 0, injections = 0, urgences = 0;

        for (LogTracabilite log : logs) {
            if (log.getIdDossierConcerne() == null) continue;

            String action = log.getActionEffectuee();

            // Constantes : déduplique par passage
            if ("MAJ_CONSTANTES".equals(action)) {
                if (!seenConstantes.add(log.getIdDossierConcerne())) continue;
            }

            var passageOpt = passageRepo.findById(log.getIdDossierConcerne());
            if (passageOpt.isEmpty()) continue;
            PassageMedical p = passageOpt.get();

            boolean urgence = p.getMotifVisite() != null
                    && p.getMotifVisite().toLowerCase().contains("urgence");

            String type, actionLabel, resume;

            switch (action) {
                case "SOIN_REALISE" -> {
                    type = "SOIN";
                    actionLabel = "Soin réalisé";
                    resume = log.getDescription() != null ? log.getDescription() : "Soin infirmier";
                    soins++;
                }
                case "INJECTION_IV" -> {
                    type = "INJECTION";
                    actionLabel = "Injection IV";
                    resume = log.getDescription() != null ? log.getDescription() : "Injection";
                    injections++;
                }
                default -> { // MAJ_CONSTANTES
                    type = urgence ? "CONSTANTES_URGENCE" : "CONSTANTES";
                    actionLabel = urgence ? "Constantes urgence" : "Constantes prises";
                    resume = buildConstantesResume(p.getConstantesVitales());
                    constantes++;
                    if (urgence) urgences++;
                }
            }

            items.add(new ActiviteInfirmierItemDto(
                    p.getIdPassage().toString(),
                    p.getPatient().getNom(),
                    p.getPatient().getPrenom(),
                    p.getMotifVisite(),
                    log.getHorodatage().format(dateFmt),
                    log.getHorodatage().format(heureFmt),
                    urgence, type, actionLabel, resume
            ));
        }

        int total = constantes + soins + injections;
        return new ActiviteInfirmierDto(total, constantes, soins, injections, urgences, items);
    }

    // Construit un résumé lisible des constantes (max 2 valeurs, les plus pertinentes en premier)
    private String buildConstantesResume(Map<String, Object> c) {
        if (c == null || c.isEmpty()) return "Constantes enregistrées";

        List<String> parts = Stream.of(
                val(c, "tension",       v -> "Tension " + v),
                val(c, "spo2",          v -> "SpO₂ " + v + "%"),
                val(c, "freqCardiaque", v -> "Pouls " + v),
                val(c, "temperature",   v -> v + "°"),
                val(c, "poids",         v -> v + " kg"),
                val(c, "freqRespi",     v -> "FR " + v + "/min")
        ).filter(s -> s != null).limit(2).collect(Collectors.toList());

        return parts.isEmpty() ? "Constantes enregistrées" : String.join(" · ", parts);
    }

    private String val(Map<String, Object> c, String key, java.util.function.Function<String, String> fmt) {
        Object v = c.get(key);
        if (v == null) return null;
        String s = v.toString().trim();
        if (s.isEmpty() || s.equals("—")) return null;
        return fmt.apply(s);
    }
}
