package com.bank.numsante.repository;

import com.bank.numsante.entity.LogTracabilite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface LogTracabiliteRepository extends JpaRepository<LogTracabilite, Long> {

    @Query("SELECT l FROM LogTracabilite l " +
           "WHERE l.idUtilisateur = :idPersonnel " +
           "AND l.actionEffectuee = 'CREATION_PATIENT' " +
           "AND l.horodatage >= :depuis " +
           "ORDER BY l.horodatage DESC")
    List<LogTracabilite> findPatientCreationsBy(
            @Param("idPersonnel") Long idPersonnel,
            @Param("depuis") LocalDateTime depuis);

    @Query("SELECT l FROM LogTracabilite l " +
           "WHERE l.idUtilisateur = :idPersonnel " +
           "AND l.actionEffectuee = 'MAJ_CONSTANTES' " +
           "AND l.horodatage >= :depuis " +
           "ORDER BY l.horodatage DESC")
    List<LogTracabilite> findConstantesByInfirmier(
            @Param("idPersonnel") Long idPersonnel,
            @Param("depuis") LocalDateTime depuis);

    @Query("SELECT l FROM LogTracabilite l " +
           "WHERE l.idUtilisateur = :idPersonnel " +
           "AND l.actionEffectuee IN ('MAJ_CONSTANTES', 'SOIN_REALISE', 'INJECTION_IV') " +
           "AND l.horodatage >= :depuis " +
           "ORDER BY l.horodatage DESC")
    List<LogTracabilite> findActesInfirmier(
            @Param("idPersonnel") Long idPersonnel,
            @Param("depuis") LocalDateTime depuis);
}