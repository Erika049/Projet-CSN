package com.bank.numsante.repository;

import com.bank.numsante.entity.PassageMedical;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface PassageMedicalRepository extends JpaRepository<PassageMedical, UUID> {

    List<PassageMedical> findByPatient_IdPatientOrderByDateAdmissionDesc(UUID idPatient);

    @Query("SELECT p FROM PassageMedical p " +
           "WHERE p.hopital.idHopital = :idHopital " +
           "AND CAST(p.dateAdmission AS date) = CURRENT_DATE " +
           "ORDER BY p.dateAdmission DESC")
    List<PassageMedical> findPassagesDuJour(@Param("idHopital") Long idHopital);

    @Query("SELECT p FROM PassageMedical p " +
           "WHERE p.createur.idPersonnel = :idPersonnel " +
           "AND p.dateAdmission >= :depuis " +
           "ORDER BY p.dateAdmission DESC")
    List<PassageMedical> findByCreateurSince(
            @Param("idPersonnel") Long idPersonnel,
            @Param("depuis") LocalDateTime depuis);
}