package com.bank.numsante.repository;

import com.bank.numsante.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    @Query("SELECT n FROM Notification n WHERE n.patient.idPatient = :idPatient " +
            "ORDER BY n.creeLe DESC")
    List<Notification> findByPatientIdOrderByDesc(UUID idPatient);

    long countByPatient_IdPatientAndLueFalse(UUID idPatient);
}