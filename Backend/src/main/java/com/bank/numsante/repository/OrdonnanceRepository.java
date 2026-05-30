package com.bank.numsante.repository;

import com.bank.numsante.entity.Ordonnance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface OrdonnanceRepository extends JpaRepository<Ordonnance, UUID> {
    List<Ordonnance> findByPatient_IdPatientOrderByDateDelivranceDesc(UUID idPatient);
    List<Ordonnance> findByPatient_IdPatientAndStatutOrderByDateDelivranceDesc(
            UUID idPatient, String statut);
}