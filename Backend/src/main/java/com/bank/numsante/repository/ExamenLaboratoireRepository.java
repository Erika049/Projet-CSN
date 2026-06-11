package com.bank.numsante.repository;

import com.bank.numsante.entity.ExamenLaboratoire;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ExamenLaboratoireRepository
        extends JpaRepository<ExamenLaboratoire, Long> {

    // Examens d'un passage
    List<ExamenLaboratoire> findByPassage_IdPassage(
            UUID idPassage);

    // Historique des examens publiés par un laborantin
    List<ExamenLaboratoire> findByLaborantin_IdPersonnelOrderByDateResultatDesc(
            Long idPersonnel);

    // Nombre d'examens publiés par un laborantin
    long countByLaborantin_IdPersonnel(Long idPersonnel);
}