package com.bank.numsante.repository;

import com.bank.numsante.entity.PassageMedical;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface PassageMedicalRepository
        extends JpaRepository<PassageMedical, UUID> {

    List<PassageMedical> findByPatient_IdPatientOrderByDateAdmissionDesc(
            UUID idPatient);

    List<PassageMedical> findByHopital_IdHopitalAndDateAdmissionAfterOrderByDateAdmissionDesc(
            Long idHopital, LocalDateTime debut);

    List<PassageMedical> findByCreateur_IdPersonnelAndDateAdmissionAfterOrderByDateAdmissionDesc(
            Long idPersonnel, LocalDateTime debut);

    @org.springframework.data.jpa.repository.Query("SELECT p FROM PassageMedical p WHERE p.hopital.idHopital = :idHopital AND p.dateAdmission >= CURRENT_DATE ORDER BY p.dateAdmission DESC")
    List<PassageMedical> findPassagesDuJour(Long idHopital);
}