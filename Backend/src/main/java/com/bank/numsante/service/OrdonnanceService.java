package com.bank.numsante.service;

import com.bank.numsante.dto.CreerOrdonnanceRequest;
import com.bank.numsante.dto.OrdonnanceDto;
import com.bank.numsante.entity.*;
import com.bank.numsante.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrdonnanceService {

    private final OrdonnanceRepository ordonnanceRepo;
    private final MedicamentRepository medicamentRepo;
    private final PassageMedicalRepository passageRepo;
    private final PersonnelMedicalRepository personnelRepo;
    private final NotificationRepository notificationRepo;

    public List<OrdonnanceDto> getOrdonnances(UUID idPatient) {
        return ordonnanceRepo
                .findByPatient_IdPatientOrderByDateDelivranceDesc(idPatient)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<OrdonnanceDto> getOrdonnancesActives(UUID idPatient) {
        return ordonnanceRepo
                .findByPatient_IdPatientAndStatutOrderByDateDelivranceDesc(
                        idPatient, "active")
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<OrdonnanceDto> getAllOrdonnancesActives() {
        return ordonnanceRepo
                .findByStatutOrderByDateDelivranceDesc("active")
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<OrdonnanceDto> getHistoriquePharmacien() {
        return ordonnanceRepo
                .findByStatutNotOrderByDateDelivranceDesc("active")
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public OrdonnanceDto getOrdonnance(UUID idOrdonnance) {
        Ordonnance ord = ordonnanceRepo.findById(idOrdonnance)
                .orElseThrow(() -> new RuntimeException("Ordonnance non trouvée"));
        return toDto(ord);
    }

    @Transactional
    public void delivrerOrdonnance(UUID idOrdonnance) {
        Ordonnance ord = ordonnanceRepo.findById(idOrdonnance)
                .orElseThrow(() -> new RuntimeException("Ordonnance non trouvée"));
        ord.setStatut("terminee");
        ordonnanceRepo.save(ord);
        
        _creerNotification(
                ord.getPatient(),
                "Ordonnance délivrée",
                "Votre ordonnance " + ord.getTitre() + " a été délivrée.",
                "ordonnance"
        );
    }

    @Transactional
    public void refuserOrdonnance(UUID idOrdonnance) {
        Ordonnance ord = ordonnanceRepo.findById(idOrdonnance)
                .orElseThrow(() -> new RuntimeException("Ordonnance non trouvée"));
        ord.setStatut("refusee");
        ordonnanceRepo.save(ord);
        
        _creerNotification(
                ord.getPatient(),
                "Ordonnance refusée",
                "Votre ordonnance " + ord.getTitre() + " a été refusée.",
                "ordonnance"
        );
    }

    @Transactional
    public OrdonnanceDto creerOrdonnance(
            CreerOrdonnanceRequest request, String username) {

        PassageMedical passage = passageRepo.findById(request.getIdPassage())
                .orElseThrow(() -> new RuntimeException("Passage non trouvé"));

        PersonnelMedical medecin = personnelRepo
                .findByIdentifiantPro(username)
                .orElseThrow(() -> new RuntimeException("Médecin non trouvé"));

        // Créer l'ordonnance
        Ordonnance ordonnance = new Ordonnance();
        ordonnance.setPatient(passage.getPatient());
        ordonnance.setPassage(passage);
        ordonnance.setMedecin(medecin);
        ordonnance.setTitre(request.getTitre());
        ordonnance.setDateDelivrance(LocalDate.now());
        ordonnance.setDateExpiration(request.getDateExpiration());
        ordonnance.setStatut("active");
        ordonnance = ordonnanceRepo.save(ordonnance);

        // Créer les médicaments
        final Ordonnance savedOrd = ordonnance;
        List<Medicament> medicaments = request.getMedicaments().stream()
                .map(m -> {
                    Medicament med = new Medicament();
                    med.setOrdonnance(savedOrd);
                    med.setNom(m.getNom());
                    med.setPosologie(m.getPosologie());
                    med.setComprimesTotaux(m.getComprimesTotaux());
                    med.setComprimesRestants(m.getComprimesTotaux());
                    return med;
                })
                .collect(Collectors.toList());
        medicamentRepo.saveAll(medicaments);
        ordonnance.setMedicaments(medicaments);

        // Notifier le patient
        _creerNotification(
                passage.getPatient(),
                "Nouvelle ordonnance",
                "Dr. " + medecin.getNom() + " a rédigé une ordonnance : "
                        + request.getTitre(),
                "ordonnance"
        );

        return toDto(ordonnance);
    }

    // Appelé automatiquement après une consultation
    @Transactional
    public void verifierExpirations(UUID idPatient) {
        List<Ordonnance> actives = ordonnanceRepo
                .findByPatient_IdPatientAndStatutOrderByDateDelivranceDesc(
                        idPatient, "active");
        for (Ordonnance ord : actives) {
            long jours = ChronoUnit.DAYS.between(
                    LocalDate.now(), ord.getDateExpiration());
            if (jours < 0) {
                ord.setStatut("expiree");
                ordonnanceRepo.save(ord);
            } else if (jours <= 3) {
                // Notifier si expire dans 3 jours
                _creerNotification(
                        ord.getPatient(),
                        "Ordonnance bientôt expirée",
                        ord.getTitre() + " — expire dans " + jours + " jour(s)",
                        "ordonnance"
                );
            }
        }
    }

    private void _creerNotification(
            Patient patient, String titre,
            String message, String type) {
        Notification notif = new Notification();
        notif.setPatient(patient);
        notif.setTitre(titre);
        notif.setMessage(message);
        notif.setType(type);
        notif.setLue(false);
        notificationRepo.save(notif);
    }

    private OrdonnanceDto toDto(Ordonnance ord) {
        long jours = ChronoUnit.DAYS.between(
                LocalDate.now(), ord.getDateExpiration());

        String medecinNom = ord.getMedecin() != null
                ? ord.getMedecin().getPrenom() + " " + ord.getMedecin().getNom()
                : "Inconnu";
        String specialite = ord.getMedecin() != null
                ? ord.getMedecin().getRole() : "";
        String hopital = (ord.getMedecin() != null
                && ord.getMedecin().getHopital() != null)
                ? ord.getMedecin().getHopital().getNom() : "";

        List<OrdonnanceDto.MedicamentDto> meds = ord.getMedicaments() == null
                ? List.of()
                : ord.getMedicaments().stream()
                .map(m -> new OrdonnanceDto.MedicamentDto(
                        m.getIdMedicament(),
                        m.getNom(),
                        m.getPosologie(),
                        m.getComprimesRestants(),
                        m.getComprimesTotaux()
                ))
                .collect(Collectors.toList());

        return new OrdonnanceDto(
                ord.getIdOrdonnance(),
                ord.getTitre(),
                medecinNom,
                specialite,
                hopital,
                ord.getDateDelivrance(),
                ord.getDateExpiration(),
                ord.getStatut(),
                (int) Math.max(0, jours),
                meds
        );
    }
}