package com.bank.numsante.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "medicaments")
@Data @NoArgsConstructor @AllArgsConstructor
public class Medicament {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idMedicament;

    @ManyToOne
    @JoinColumn(name = "id_ordonnance", nullable = false)
    private Ordonnance ordonnance;

    @Column(nullable = false)
    private String nom;

    @Column(nullable = false)
    private String posologie;

    @Column(name = "comprimes_restants")
    private Integer comprimesRestants;

    @Column(name = "comprimes_totaux")
    private Integer comprimesTotaux;
}