package com.bank.numsante.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "ordonnances")
@Data @NoArgsConstructor @AllArgsConstructor
public class Ordonnance {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id_ordonnance", updatable = false, nullable = false)
    private UUID idOrdonnance;

    @ManyToOne
    @JoinColumn(name = "id_patient", nullable = false)
    private Patient patient;

    @ManyToOne
    @JoinColumn(name = "id_passage")
    private PassageMedical passage;

    @ManyToOne
    @JoinColumn(name = "id_medecin")
    private PersonnelMedical medecin;

    @Column(nullable = false)
    private String titre;

    @Column(name = "date_delivrance", nullable = false)
    private LocalDate dateDelivrance;

    @Column(name = "date_expiration", nullable = false)
    private LocalDate dateExpiration;

    @Column(nullable = false)
    private String statut = "active"; // active | terminee | expiree

    @CreationTimestamp
    @Column(name = "cree_le")
    private LocalDateTime creeLe;

    @OneToMany(mappedBy = "ordonnance",
            cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Medicament> medicaments;
}