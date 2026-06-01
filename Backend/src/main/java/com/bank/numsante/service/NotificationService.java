package com.bank.numsante.service;

import com.bank.numsante.dto.NotificationDto;
import com.bank.numsante.entity.Notification;
import com.bank.numsante.entity.Patient;
import com.bank.numsante.repository.NotificationRepository;
import com.bank.numsante.repository.PatientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepo;
    private final PatientRepository patientRepo;

    public List<NotificationDto> getNotifications(UUID idPatient) {
        return notificationRepo
                .findByPatientIdOrderByDesc(idPatient)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public long getNombreNonLues(UUID idPatient) {
        return notificationRepo.countByPatient_IdPatientAndLueFalse(idPatient);
    }

    @Transactional
    public void marquerToutesLues(UUID idPatient) {
        List<Notification> notifs = notificationRepo
                .findByPatientIdOrderByDesc(idPatient);
        notifs.forEach(n -> n.setLue(true));
        notificationRepo.saveAll(notifs);
    }

    @Transactional
    public void marquerLue(Long idNotification) {
        notificationRepo.findById(idNotification).ifPresent(n -> {
            n.setLue(true);
            notificationRepo.save(n);
        });
    }

    public void creerNotification(UUID idPatient, String titre,
                                  String message, String type) {
        Patient patient = patientRepo.findById(idPatient)
                .orElseThrow(() -> new RuntimeException("Patient non trouvé"));
        Notification notif = new Notification();
        notif.setPatient(patient);
        notif.setTitre(titre);
        notif.setMessage(message);
        notif.setType(type);
        notif.setLue(false);
        notificationRepo.save(notif);
    }

    private NotificationDto toDto(Notification n) {
        return new NotificationDto(
                n.getIdNotification(),
                n.getTitre(),
                n.getMessage(),
                n.getType(),
                n.isLue(),
                n.getCreeLe()
        );
    }
}