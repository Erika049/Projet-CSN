package com.bank.numsante.repository;

import com.bank.numsante.entity.LogTracabilite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;

public interface LogTracabiliteRepository
        extends JpaRepository<LogTracabilite, Long> {

    List<LogTracabilite> findAllByOrderByHorodatageDesc(
            Pageable pageable);

    @Query("SELECT l FROM LogTracabilite l WHERE l.idUtilisateur = :idPersonnel AND l.horodatage >= :depuis ORDER BY l.horodatage DESC")
    List<LogTracabilite> findActesInfirmier(@Param("idPersonnel") Long idPersonnel, @Param("depuis") LocalDateTime depuis);
}